// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/verification/ProofOfHumanity.sol";

contract ProofOfHumanityTest is Test {
    ProofOfHumanity public poh;

    address public owner = address(1);
    address public verifier = address(2);
    address public human1 = address(3);
    address public human2 = address(4);
    address public sybil = address(5);

    function setUp() public {
        vm.prank(owner);
        poh = new ProofOfHumanity(owner);

        vm.prank(owner);
        poh.addVerifier(verifier);
    }

    function testSubmitProofWithHighConfidence() public {
        bytes32 contextHash = keccak256("test-context");
        address[] memory connections = new address[](2);
        connections[0] = human2;
        connections[1] = verifier;

        vm.prank(human1);
        poh.submitProof(contextHash, 80, connections);

        (
            ProofOfHumanity.VerificationStatus status,
            ,
            uint8 confidence,
            ,

        ) = poh.getProof(human1);

        assertEq(
            uint(status),
            uint(ProofOfHumanity.VerificationStatus.VERIFIED)
        );
        assertEq(confidence, 80);
    }

    function testSubmitProofWithLowConfidence() public {
        bytes32 contextHash = keccak256("test-context");
        address[] memory connections = new address[](0);

        vm.prank(human1);
        poh.submitProof(contextHash, 50, connections);

        (ProofOfHumanity.VerificationStatus status, , , , ) = poh.getProof(
            human1
        );

        assertEq(
            uint(status),
            uint(ProofOfHumanity.VerificationStatus.PENDING)
        );
    }

    function testVerifyHuman() public {
        bytes32 contextHash = keccak256("test-context");
        address[] memory connections = new address[](0);

        vm.prank(human1);
        poh.submitProof(contextHash, 75, connections);

        vm.prank(verifier);
        poh.verifyHuman(human1, true);

        assertTrue(poh.isVerified(human1));
    }

    function testCannotVerifyWithoutProof() public {
        vm.prank(verifier);
        vm.expectRevert("No proof submitted");
        poh.verifyHuman(human1, true);
    }

    function testFlagSuspicious() public {
        bytes32 contextHash = keccak256("test-context");
        address[] memory connections = new address[](0);

        vm.prank(sybil);
        poh.submitProof(contextHash, 75, connections);

        vm.prank(verifier);
        poh.flagSuspicious(sybil, "Duplicate social graph detected");

        (ProofOfHumanity.VerificationStatus status, , , , ) = poh.getProof(
            sybil
        );

        assertEq(
            uint(status),
            uint(ProofOfHumanity.VerificationStatus.FLAGGED)
        );
    }

    function testBanAddress() public {
        bytes32 contextHash = keccak256("test-context");
        address[] memory connections = new address[](0);

        vm.prank(sybil);
        poh.submitProof(contextHash, 75, connections);

        vm.prank(owner);
        poh.banAddress(sybil);

        assertFalse(poh.isVerified(sybil));
    }

    function testAddSocialConnection() public {
        // Setup human1 and human2 as verified
        bytes32 contextHash1 = keccak256("context1");
        bytes32 contextHash2 = keccak256("context2");
        address[] memory connections = new address[](0);

        vm.prank(human1);
        poh.submitProof(contextHash1, 80, connections);
        vm.prank(verifier);
        poh.verifyHuman(human1, true);

        vm.prank(human2);
        poh.submitProof(contextHash2, 80, connections);
        vm.prank(verifier);
        poh.verifyHuman(human2, true);

        // Add connection
        vm.prank(human1);
        poh.addSocialConnection(human2);

        (, , , , uint256 connectionCount) = poh.getProof(human1);
        assertEq(connectionCount, 1);
    }

    function testUpdateMinimumConfidence() public {
        vm.prank(owner);
        poh.updateMinimumConfidence(80);

        assertEq(poh.minimumConfidenceScore(), 80);
    }

    function testGetSocialMetrics() public {
        bytes32 contextHash = keccak256("test-context");
        address[] memory connections = new address[](2);
        connections[0] = human2;
        connections[1] = verifier;

        vm.prank(human1);
        poh.submitProof(contextHash, 80, connections);

        (uint256 count, ) = poh.getSocialMetrics(human1);
        assertEq(count, 2);
    }

    function testOnlyVerifierCanFlag() public {
        vm.prank(human1);
        vm.expectRevert("Not authorized");
        poh.flagSuspicious(sybil, "test");
    }
}
