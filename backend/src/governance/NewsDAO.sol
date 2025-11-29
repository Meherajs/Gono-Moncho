// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../staking/NewsStaking.sol";
import "../tokens/CRED.sol";
import "./libraries/QuadraticVoting.sol";
import "./libraries/ReputationWeightedVoting.sol";
import "./interfaces/IDelegation.sol";

contract NewsDAO is Ownable {
    NewsStaking public staking;
    CRED public credToken;
    IDelegation public delegation;

    enum ProposalType {
        FUNDING,
        POLICY,
        OTHER
    }

    struct Proposal {
        uint256 id;
        ProposalType pType;
        address proposer;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 createdAt;
        bool executed;
    }

    Proposal[] public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // Minimum voting power required to create proposals
    uint256 public proposalThreshold = 100 * 1e18;

    // Enable/disable reputation-weighted voting
    bool public useReputationWeighting = true;

    event ProposalCreated(uint256 indexed proposalId, address indexed proposer);
    event Voted(
        uint256 indexed proposalId,
        address indexed voter,
        bool support,
        uint256 votes
    );
    event VotingModeChanged(bool useReputationWeighting);

    constructor(
        address _staking,
        address _credToken,
        address _delegation,
        address initialOwner
    ) Ownable(initialOwner) {
        staking = NewsStaking(_staking);
        credToken = CRED(_credToken);
        delegation = IDelegation(_delegation);
    }

    function createProposal(ProposalType pType) external returns (uint256) {
        // Check if proposer has sufficient voting power
        if (useReputationWeighting) {
            require(
                ReputationWeightedVoting.meetsVotingThreshold(
                    staking,
                    credToken,
                    msg.sender,
                    proposalThreshold
                ),
                "Insufficient voting power to create proposal"
            );
        }

        uint256 proposalId = proposals.length;
        proposals.push(
            Proposal({
                id: proposalId,
                pType: pType,
                proposer: msg.sender,
                forVotes: 0,
                againstVotes: 0,
                createdAt: block.timestamp,
                executed: false
            })
        );
        emit ProposalCreated(proposalId, msg.sender);
        return proposalId;
    }

    function vote(uint256 proposalId, bool support, uint256 votes) external {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.createdAt > 0, "Invalid proposal");
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        // Calculate actual voting power using reputation weighting
        uint256 actualVotingPower;
        if (useReputationWeighting) {
            actualVotingPower = ReputationWeightedVoting.calculateVotingPower(
                staking,
                credToken,
                msg.sender
            );
            require(votes <= actualVotingPower, "Insufficient voting power");
        } else {
            // Fall back to pure NEWS token voting
            (uint256 stake, ) = staking.stakes(msg.sender);
            require(votes <= stake, "Insufficient stake");
        }

        uint256 totalVotes = votes;

        // Apply quadratic voting for funding proposals first
        if (proposal.pType == ProposalType.FUNDING) {
            QuadraticVoting.validateVote(staking, msg.sender, votes);
            uint256 cost = QuadraticVoting.calculateCost(votes);
            staking.slash(msg.sender, cost);
        }

        // Add the caller's votes
        if (support) {
            proposal.forVotes += votes;
        } else {
            proposal.againstVotes += votes;
        }

        // Check for delegations and add delegated votes
        address[] memory stakers = staking.getAllStakers();
        for (uint i = 0; i < stakers.length; i++) {
            if (delegation.getDelegate(stakers[i], 0) == msg.sender) {
                // Calculate delegated voting power
                uint256 delegatedPower;
                if (useReputationWeighting) {
                    delegatedPower = ReputationWeightedVoting
                        .calculateVotingPower(staking, credToken, stakers[i]);
                } else {
                    (delegatedPower, ) = staking.stakes(stakers[i]);
                }

                if (support) {
                    proposal.forVotes += delegatedPower;
                } else {
                    proposal.againstVotes += delegatedPower;
                }
                break; // Only allow one delegation for now
            }
        }

        hasVoted[proposalId][msg.sender] = true;
        emit Voted(proposalId, msg.sender, support, totalVotes);
    }

    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");
        require(
            block.timestamp > proposal.createdAt + 3 days,
            "Voting period ongoing"
        );

        // Execution logic would go here
        proposal.executed = true;
    }

    /**
     * @notice Get voting power for an address
     * @param voter Address to query
     * @return votingPower Current voting power
     */
    function getVotingPower(
        address voter
    ) external view returns (uint256 votingPower) {
        if (useReputationWeighting) {
            return
                ReputationWeightedVoting.calculateVotingPower(
                    staking,
                    credToken,
                    voter
                );
        } else {
            (votingPower, ) = staking.stakes(voter);
            return votingPower;
        }
    }

    /**
     * @notice Get detailed voting power breakdown
     * @param voter Address to query
     */
    function getVotingPowerBreakdown(
        address voter
    )
        external
        view
        returns (
            uint256 newsStake,
            uint256 credBalance,
            uint256 economicPower,
            uint256 reputationPower,
            uint256 totalPower
        )
    {
        return
            ReputationWeightedVoting.getVotingPowerBreakdown(
                staking,
                credToken,
                voter
            );
    }

    /**
     * @notice Toggle reputation-weighted voting (DAO governance action)
     * @param enabled True to enable, false to use pure NEWS voting
     */
    function setReputationWeighting(bool enabled) external onlyOwner {
        useReputationWeighting = enabled;
        emit VotingModeChanged(enabled);
    }

    /**
     * @notice Update proposal threshold
     * @param newThreshold New minimum voting power required
     */
    function updateProposalThreshold(uint256 newThreshold) external onlyOwner {
        proposalThreshold = newThreshold;
    }
}
