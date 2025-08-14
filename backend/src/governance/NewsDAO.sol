// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../staking/NewsStaking.sol";
import "../tokens/CRED.sol";
import "./libraries/QuadraticVoting.sol";
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

    event ProposalCreated(uint256 indexed proposalId, address indexed proposer);
    event Voted(
        uint256 indexed proposalId,
        address indexed voter,
        bool support,
        uint256 votes
    );

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

        // Apply quadratic voting for funding proposals
        if (proposal.pType == ProposalType.FUNDING) {
            QuadraticVoting.validateVote(staking, msg.sender, votes);
            uint256 cost = QuadraticVoting.calculateCost(votes);
            staking.slash(msg.sender, cost);
        }

        if (support) {
            proposal.forVotes += votes;
        } else {
            proposal.againstVotes += votes;
        }

        hasVoted[proposalId][msg.sender] = true;
        emit Voted(proposalId, msg.sender, support, votes);
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
}
