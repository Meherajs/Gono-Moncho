// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/verification/ZeroKnowledgePublishing.sol";
import "../src/verification/ReporterRegistry.sol";
import "../src/tokens/NEWS.sol";

contract ZeroKnowledgePublishingTest is Test {
    ZeroKnowledgePublishing public zkPublish;
    ReporterRegistry public registry;
    NEWS public news;

    address public owner = address(1);
    address public reporter = address(2);
    address public verifier = address(3);

    function setUp() public {
        vm.startPrank(owner);

        news = new NEWS(owner);
        registry = new ReporterRegistry(address(news), owner);
        zkPublish = new ZeroKnowledgePublishing(address(registry), owner);

        // Register reporter
        news.mint(reporter, 1000 * 1e18);
        vm.stopPrank();

        vm.startPrank(reporter);
        news.approve(address(registry), 100 * 1e18);
        registry.register("John Doe", "Investigative Reporter");
        vm.stopPrank();
    }

    function testCommitAnonymousPublish() public {
        bytes32 contentHash = keccak256("secret content");
        bytes32 commitment = keccak256(abi.encodePacked(contentHash, reporter));

        vm.prank(reporter);
        uint256 commitId = zkPublish.commitAnonymousPublish(
            commitment,
            "Investigative"
        );

        (
            bytes32 storedCommitment,
            ,
            uint256 timestamp,
            ,
            uint8 status,

        ) = zkPublish.getCommitment(commitId);

        assertEq(storedCommitment, commitment);
        assertEq(timestamp, block.timestamp);
        assertEq(status, 0); // COMMITTED = 0
    }

    function testRevealContent() public {
        bytes32 contentHash = keccak256("secret content");
        bytes32 commitment = keccak256(abi.encodePacked(contentHash, reporter));

        vm.prank(reporter);
        uint256 commitId = zkPublish.commitAnonymousPublish(
            commitment,
            "Investigative"
        );

        // Fast forward past commit period
        vm.warp(block.timestamp + 2 hours);

        vm.prank(reporter);
        zkPublish.revealContent(commitId, contentHash, reporter);

        (, bytes32 revealed, , , uint8 status, ) = zkPublish.getCommitment(
            commitId
        );

        assertEq(revealed, contentHash);
        assertEq(status, 1); // REVEALED = 1
    }

    function testCannotRevealTooEarly() public {
        bytes32 contentHash = keccak256("secret content");
        bytes32 commitment = keccak256(abi.encodePacked(contentHash, reporter));

        vm.prank(reporter);
        uint256 commitId = zkPublish.commitAnonymousPublish(
            commitment,
            "Investigative"
        );

        vm.prank(reporter);
        vm.expectRevert("Must wait minimum commit period");
        zkPublish.revealContent(commitId, contentHash, reporter);
    }

    function testCannotRevealTooLate() public {
        bytes32 contentHash = keccak256("secret content");
        bytes32 commitment = keccak256(abi.encodePacked(contentHash, reporter));

        vm.prank(reporter);
        uint256 commitId = zkPublish.commitAnonymousPublish(
            commitment,
            "Investigative"
        );

        // Fast forward past max reveal period
        vm.warp(block.timestamp + 25 hours);

        vm.prank(reporter);
        vm.expectRevert("Reveal period expired");
        zkPublish.revealContent(commitId, contentHash, reporter);
    }

    function testInvalidReveal() public {
        bytes32 contentHash = keccak256("secret content");
        bytes32 commitment = keccak256(abi.encodePacked(contentHash, reporter));

        vm.prank(reporter);
        uint256 commitId = zkPublish.commitAnonymousPublish(
            commitment,
            "Investigative"
        );

        vm.warp(block.timestamp + 2 hours);

        bytes32 wrongContent = keccak256("wrong content");

        vm.prank(reporter);
        vm.expectRevert("Invalid reveal");
        zkPublish.revealContent(commitId, wrongContent, reporter);
    }

    function testVerifyProof() public {
        // Simple proof structure for testing
        uint256[2] memory a = [uint256(1), uint256(2)];
        uint256[2][2] memory b = [
            [uint256(3), uint256(4)],
            [uint256(5), uint256(6)]
        ];
        uint256[2] memory c = [uint256(7), uint256(8)];
        uint256[2] memory input = [uint256(9), uint256(10)];

        vm.prank(owner);
        zkPublish.verifyProof(a, b, c, input);

        // Note: In production, this would interact with a real zkSNARK verifier
        // For testing, we just verify the function executes
    }

    function testUpdateMinCommitPeriod() public {
        vm.prank(owner);
        zkPublish.updateMinCommitPeriod(2 hours);

        assertEq(zkPublish.minCommitPeriod(), 2 hours);
    }

    function testUpdateMaxRevealPeriod() public {
        vm.prank(owner);
        zkPublish.updateMaxRevealPeriod(48 hours);

        assertEq(zkPublish.maxRevealPeriod(), 48 hours);
    }

    function testNullifierPreventsDoubleUse() public {
        bytes32 contentHash = keccak256("secret content");
        bytes32 commitment = keccak256(abi.encodePacked(contentHash, reporter));

        vm.prank(reporter);
        uint256 commitId = zkPublish.commitAnonymousPublish(
            commitment,
            "Investigative"
        );

        vm.warp(block.timestamp + 2 hours);

        vm.prank(reporter);
        zkPublish.revealContent(commitId, contentHash, reporter);

        // Try to use same nullifier
        bytes32 newCommitment = keccak256(
            abi.encodePacked(contentHash, reporter)
        );

        vm.prank(reporter);
        vm.expectRevert("Nullifier already used");
        zkPublish.commitAnonymousPublish(newCommitment, "Investigative");
    }
}
