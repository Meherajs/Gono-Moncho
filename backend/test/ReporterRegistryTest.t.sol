// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/verification/ReporterRegistry.sol";
import "../src/tokens/NEWS.sol";

contract ReporterRegistryTest is Test {
    ReporterRegistry public registry;
    NEWS public newsToken;

    address public owner = address(1);
    address public reporter = address(2);
    address public analyzer = address(3);
    address public verifier = address(4);
    address public user = address(5);

    function setUp() public {
        vm.startPrank(owner);

        // Deploy NEWS token
        newsToken = new NEWS(owner);

        // Deploy ReporterRegistry
        registry = new ReporterRegistry(address(newsToken), owner);

        vm.stopPrank();

        // Distribute tokens for testing
        vm.prank(owner);
        newsToken.transfer(reporter, 1000 * 1e18);

        vm.prank(owner);
        newsToken.transfer(analyzer, 500 * 1e18);

        vm.prank(owner);
        newsToken.transfer(verifier, 300 * 1e18);
    }

    function testRegisterReporter() public {
        vm.startPrank(reporter);

        string memory metadata = "QmTestMetadataHash";
        registry.registerReporter(metadata, ReporterRegistry.UserRole.REPORTER);

        (
            ReporterRegistry.UserRole role,
            ReporterRegistry.ReporterStatus status,
            ,
            ,
            ,
            string memory ipfsMetadata,
            ,
            bool isFreeTestAccount
        ) = registry.getReporterProfile(reporter);

        assertEq(uint(role), uint(ReporterRegistry.UserRole.REPORTER));
        assertEq(uint(status), uint(ReporterRegistry.ReporterStatus.PENDING));
        assertEq(ipfsMetadata, metadata);
        assertTrue(isFreeTestAccount); // Testing mode is on by default

        vm.stopPrank();
    }

    function testStakeTokens() public {
        // Register first
        vm.prank(reporter);
        registry.registerReporter("QmTest", ReporterRegistry.UserRole.REPORTER);

        // Approve and stake
        vm.startPrank(reporter);
        newsToken.approve(address(registry), 100 * 1e18);
        registry.stakeTokens(100 * 1e18);
        vm.stopPrank();

        (, , uint256 stakedAmount, , , , , ) = registry.getReporterProfile(
            reporter
        );
        assertEq(stakedAmount, 100 * 1e18);
    }

    function testVerifyReporter() public {
        // Register reporter
        vm.prank(reporter);
        registry.registerReporter("QmTest", ReporterRegistry.UserRole.REPORTER);

        // Verify reporter (owner is authorized verifier by default)
        vm.prank(owner);
        registry.verifyReporter(reporter, true);

        (, ReporterRegistry.ReporterStatus status, , , , , , ) = registry
            .getReporterProfile(reporter);
        assertEq(uint(status), uint(ReporterRegistry.ReporterStatus.VERIFIED));
    }

    function testCanPublishInTestingMode() public {
        // Register and verify
        vm.prank(reporter);
        registry.registerReporter("QmTest", ReporterRegistry.UserRole.REPORTER);

        vm.prank(owner);
        registry.verifyReporter(reporter, true);

        // Should be able to publish without stake in testing mode
        assertTrue(registry.canPublish(reporter));
    }

    function testCannotPublishWithoutVerification() public {
        vm.prank(reporter);
        registry.registerReporter("QmTest", ReporterRegistry.UserRole.REPORTER);

        // Not verified yet
        assertFalse(registry.canPublish(reporter));
    }

    function testCannotPublishWhenTestingModeOff() public {
        // Register and verify
        vm.prank(reporter);
        registry.registerReporter("QmTest", ReporterRegistry.UserRole.REPORTER);

        vm.prank(owner);
        registry.verifyReporter(reporter, true);

        // Turn off testing mode
        vm.prank(owner);
        registry.setTestingMode(false);

        // Should not be able to publish without stake
        assertFalse(registry.canPublish(reporter));

        // Stake tokens
        vm.startPrank(reporter);
        newsToken.approve(address(registry), 100 * 1e18);
        registry.stakeTokens(100 * 1e18);
        vm.stopPrank();

        // Now should be able to publish
        assertTrue(registry.canPublish(reporter));
    }

    function testWithdrawStake() public {
        // Register, stake, and verify
        vm.prank(reporter);
        registry.registerReporter("QmTest", ReporterRegistry.UserRole.REPORTER);

        vm.startPrank(reporter);
        newsToken.approve(address(registry), 150 * 1e18);
        registry.stakeTokens(150 * 1e18);
        vm.stopPrank();

        vm.prank(owner);
        registry.verifyReporter(reporter, true);

        uint256 balanceBefore = newsToken.balanceOf(reporter);

        // Withdraw some stake (in testing mode, can withdraw all)
        vm.prank(reporter);
        registry.withdrawStake(50 * 1e18);

        uint256 balanceAfter = newsToken.balanceOf(reporter);
        assertEq(balanceAfter - balanceBefore, 50 * 1e18);
    }

    function testRegisterAnalyzer() public {
        vm.prank(analyzer);
        registry.registerReporter(
            "QmAnalyzer",
            ReporterRegistry.UserRole.ANALYZER
        );

        (ReporterRegistry.UserRole role, , , , , , , ) = registry
            .getReporterProfile(analyzer);
        assertEq(uint(role), uint(ReporterRegistry.UserRole.ANALYZER));
    }

    function testRegisterVerifier() public {
        vm.prank(verifier);
        registry.registerReporter(
            "QmVerifier",
            ReporterRegistry.UserRole.VERIFIER
        );

        (ReporterRegistry.UserRole role, , , , , , , ) = registry
            .getReporterProfile(verifier);
        assertEq(uint(role), uint(ReporterRegistry.UserRole.VERIFIER));
    }

    function testCanVerify() public {
        // Register and verify as VERIFIER
        vm.prank(verifier);
        registry.registerReporter(
            "QmVerifier",
            ReporterRegistry.UserRole.VERIFIER
        );

        vm.prank(owner);
        registry.verifyReporter(verifier, true);

        // Should be able to verify in testing mode
        assertTrue(registry.canVerify(verifier));
    }

    function testReporterCannotVerify() public {
        // Register and verify as REPORTER
        vm.prank(reporter);
        registry.registerReporter(
            "QmReporter",
            ReporterRegistry.UserRole.REPORTER
        );

        vm.prank(owner);
        registry.verifyReporter(reporter, true);

        // Reporter cannot verify (only ANALYZER and VERIFIER can)
        assertFalse(registry.canVerify(reporter));
    }

    function testRejectReporter() public {
        vm.prank(reporter);
        registry.registerReporter("QmTest", ReporterRegistry.UserRole.REPORTER);

        // Reject reporter
        vm.prank(owner);
        registry.verifyReporter(reporter, false);

        (, ReporterRegistry.ReporterStatus status, , , , , , ) = registry
            .getReporterProfile(reporter);
        assertEq(uint(status), uint(ReporterRegistry.ReporterStatus.REJECTED));

        // Cannot publish when rejected
        assertFalse(registry.canPublish(reporter));
    }

    function testSuspendReporter() public {
        // Register and verify
        vm.prank(reporter);
        registry.registerReporter("QmTest", ReporterRegistry.UserRole.REPORTER);

        vm.prank(owner);
        registry.verifyReporter(reporter, true);

        // Suspend reporter
        vm.prank(owner);
        registry.suspendReporter(reporter);

        (, ReporterRegistry.ReporterStatus status, , , , , , ) = registry
            .getReporterProfile(reporter);
        assertEq(uint(status), uint(ReporterRegistry.ReporterStatus.SUSPENDED));

        // Cannot publish when suspended
        assertFalse(registry.canPublish(reporter));
    }

    function testReinstateReporter() public {
        // Suspend reporter first
        vm.prank(reporter);
        registry.registerReporter("QmTest", ReporterRegistry.UserRole.REPORTER);

        vm.prank(owner);
        registry.verifyReporter(reporter, true);

        vm.prank(owner);
        registry.suspendReporter(reporter);

        // Reinstate
        vm.prank(owner);
        registry.reinstateReporter(reporter);

        (, ReporterRegistry.ReporterStatus status, , , , , , ) = registry
            .getReporterProfile(reporter);
        assertEq(uint(status), uint(ReporterRegistry.ReporterStatus.VERIFIED));

        // Can publish again
        assertTrue(registry.canPublish(reporter));
    }
}
