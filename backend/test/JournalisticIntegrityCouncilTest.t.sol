// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/verification/JournalisticIntegrityCouncil.sol";
import "../src/tokens/CRED.sol";

contract JournalisticIntegrityCouncilTest is Test {
    JournalisticIntegrityCouncil public council;
    CRED public cred;

    address public owner = address(1);
    address public member1 = address(2);
    address public member2 = address(3);
    address public member3 = address(4);
    address public reporter = address(5);

    function setUp() public {
        vm.startPrank(owner);

        cred = new CRED(owner);
        council = new JournalisticIntegrityCouncil(address(cred), owner);

        // Fund council with CRED for compensation
        cred.mint(address(council), 10000 * 1e18);

        // Add council members
        council.addMember(member1, "Investigative", 5);
        council.addMember(member2, "Political", 3);
        council.addMember(member3, "Investigative", 7);

        vm.stopPrank();
    }

    function testAddMember() public {
        vm.prank(owner);
        address newMember = address(6);
        council.addMember(newMember, "Science", 4);

        (bool active, , , ) = council.getMemberInfo(newMember);
        assertTrue(active);
    }

    function testCannotAddDuplicateMember() public {
        vm.prank(owner);
        vm.expectRevert("Already a member");
        council.addMember(member1, "Investigative", 5);
    }

    function testRemoveMember() public {
        vm.prank(owner);
        council.removeMember(member1);

        (bool active, , , ) = council.getMemberInfo(member1);
        assertFalse(active);
    }

    function testRequestReview() public {
        bytes32 contentHash = keccak256("contentHash");

        vm.prank(reporter);
        uint256 reviewId = council.requestReview(
            contentHash,
            "Investigative",
            "High impact investigation"
        );

        (
            bytes32 hash,
            ,
            ,
            uint8 votesFor,
            uint8 votesAgainst,
            ,
            bool finalized,

        ) = council.getReview(reviewId);

        assertEq(hash, contentHash);
        assertEq(votesFor, 0);
        assertEq(votesAgainst, 0);
        assertFalse(finalized);
    }

    function testCastVote() public {
        bytes32 contentHash = keccak256("contentHash");

        vm.prank(reporter);
        uint256 reviewId = council.requestReview(
            contentHash,
            "Investigative",
            "High impact"
        );

        vm.prank(member1);
        council.castVote(reviewId, true, "Thoroughly vetted, credible sources");

        (, , , uint8 votesFor, , , , ) = council.getReview(reviewId);
        assertEq(votesFor, 1);
    }

    function testCannotVoteTwice() public {
        bytes32 contentHash = keccak256("contentHash");

        vm.prank(reporter);
        uint256 reviewId = council.requestReview(
            contentHash,
            "Investigative",
            "High impact"
        );

        vm.prank(member1);
        council.castVote(reviewId, true, "Approved");

        vm.prank(member1);
        vm.expectRevert("Already voted");
        council.castVote(reviewId, true, "Approved again");
    }

    function testReviewFinalization() public {
        bytes32 contentHash = keccak256("contentHash");

        vm.prank(reporter);
        uint256 reviewId = council.requestReview(
            contentHash,
            "Investigative",
            "High impact"
        );

        // Get total members with specialty
        vm.prank(member1);
        council.castVote(reviewId, true, "Approved");

        vm.prank(member3);
        council.castVote(reviewId, true, "Approved");

        (, , , , , , bool finalized, bool approved) = council.getReview(
            reviewId
        );
        assertTrue(finalized);
        assertTrue(approved);
    }

    function testReviewRejection() public {
        bytes32 contentHash = keccak256("contentHash");

        vm.prank(reporter);
        uint256 reviewId = council.requestReview(
            contentHash,
            "Investigative",
            "High impact"
        );

        vm.prank(member1);
        council.castVote(reviewId, false, "Sources not credible");

        vm.prank(member3);
        council.castVote(reviewId, false, "Lacks evidence");

        (, , , , , , bool finalized, bool approved) = council.getReview(
            reviewId
        );
        assertTrue(finalized);
        assertFalse(approved);
    }

    function testCompensation() public {
        bytes32 contentHash = keccak256("contentHash");

        vm.prank(reporter);
        uint256 reviewId = council.requestReview(
            contentHash,
            "Investigative",
            "High impact"
        );

        uint256 balanceBefore = cred.balanceOf(member1);

        vm.prank(member1);
        council.castVote(reviewId, true, "Approved");

        vm.prank(member3);
        council.castVote(reviewId, true, "Approved");

        uint256 balanceAfter = cred.balanceOf(member1);
        assertTrue(balanceAfter > balanceBefore);
    }

    function testUpdateQuorum() public {
        vm.prank(owner);
        council.updateQuorum(80);

        assertEq(council.quorumPercentage(), 80);
    }

    function testUpdateCompensation() public {
        vm.prank(owner);
        council.updateCompensation(75 * 1e18);

        assertEq(council.compensationPerReview(), 75 * 1e18);
    }

    function testOnlyMembersCanVote() public {
        bytes32 contentHash = keccak256("contentHash");

        vm.prank(reporter);
        uint256 reviewId = council.requestReview(
            contentHash,
            "Investigative",
            "High impact"
        );

        vm.prank(reporter);
        vm.expectRevert("Not a member");
        council.castVote(reviewId, true, "Approved");
    }
}
