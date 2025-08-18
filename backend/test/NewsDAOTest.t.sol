// test/NewsDAOTest.t.sol
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/tokens/NEWS.sol";
import "../src/tokens/CRED.sol";
import "../src/staking/NewsStaking.sol";
import "../src/governance/NewsDAO.sol";
import "../src/governance/libraries/DelegationRegistry.sol";

contract NewsDAOTest is Test {
    NEWS public news;
    CRED public cred;
    NewsStaking public staking;
    DelegationRegistry public delegation;
    NewsDAO public dao;

    address owner = address(1);
    address user1 = address(2);
    address user2 = address(3);
    uint256 constant INITIAL_STAKE = 10000 * 1e18;

    function setUp() public {
        // Deploy contracts
        news = new NEWS(owner);
        cred = new CRED(owner);
        staking = new NewsStaking(address(news), address(cred), owner);
        delegation = new DelegationRegistry();
        dao = new NewsDAO(
            address(staking),
            address(cred),
            address(delegation),
            owner
        );

        // Setup tokens and staking
        vm.startPrank(owner);
        news.mint(user1, INITIAL_STAKE);
        news.mint(user2, INITIAL_STAKE);
        staking.setGovernance(address(dao));
        vm.stopPrank();

        // Stake tokens
        vm.startPrank(user1);
        news.approve(address(staking), INITIAL_STAKE);
        staking.stake(INITIAL_STAKE);
        vm.stopPrank();

        vm.startPrank(user2);
        news.approve(address(staking), INITIAL_STAKE);
        staking.stake(INITIAL_STAKE);
        vm.stopPrank();
    }

    function testProposalCreation() public {
        vm.prank(user1);
        uint256 proposalId = dao.createProposal(NewsDAO.ProposalType.FUNDING);

        (, , address proposer, , , , ) = dao.proposals(proposalId);
        assertEq(proposer, user1);
    }

    function testQuadraticVoting() public {
        // Create proposal
        vm.prank(user1);
        uint256 proposalId = dao.createProposal(NewsDAO.ProposalType.FUNDING);

        // Vote with quadratic cost
        vm.prank(user1);
        dao.vote(proposalId, true, 5); // Should cost 25 tokens (5^2)

        // Check votes counted correctly
        (, , , uint256 forVotes, , , ) = dao.proposals(proposalId);
        assertEq(forVotes, 10); // 5 from user1 + 5 from delegated vote

        // Check stake was slashed correctly
        (uint256 remainingStake, ) = staking.stakes(user1);
        assertEq(remainingStake, INITIAL_STAKE - 25); // Original stake - quadratic cost
    }

    function testVoteDelegation() public {
        // User2 delegates to User1
        vm.prank(user2);
        delegation.setDelegate(0, user1); // Topic 0 = general

        // Create proposal
        vm.prank(user1);
        uint256 proposalId = dao.createProposal(NewsDAO.ProposalType.POLICY);

        // User1 votes for both
        vm.prank(user1);
        dao.vote(proposalId, true, 5);

        // Check both votes counted
        (, , , uint256 forVotes, , , ) = dao.proposals(proposalId);
        assertEq(forVotes, 10); // 5 from user1 + 5 from delegated user2
    }

    function testProposalExecution() public {
        vm.prank(user1);
        uint256 proposalId = dao.createProposal(NewsDAO.ProposalType.FUNDING);

        // Fast-forward time
        vm.warp(block.timestamp + 4 days);

        vm.prank(user1);
        dao.executeProposal(proposalId);

        (, , , , , , bool executed) = dao.proposals(proposalId);
        assertTrue(executed);
    }
}
