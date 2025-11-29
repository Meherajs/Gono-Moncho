// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/tokens/CREDRewardDistributor.sol";
import "../src/tokens/CRED.sol";
import "../src/tokens/NEWS.sol";
import "../src/staking/NewsStaking.sol";
import "../src/verification/ReporterRegistry.sol";

contract CREDRewardDistributorTest is Test {
    CREDRewardDistributor public distributor;
    CRED public cred;
    NEWS public news;
    NewsStaking public staking;
    ReporterRegistry public registry;

    address public owner = address(1);
    address public reporter = address(2);
    address public verifier = address(3);
    address public staker = address(4);

    function setUp() public {
        vm.startPrank(owner);

        // Deploy tokens
        news = new NEWS(owner);
        cred = new CRED(owner);

        // Deploy staking
        staking = new NewsStaking(address(news), address(cred), owner);

        // Deploy registry
        registry = new ReporterRegistry(address(news), owner);

        // Deploy distributor
        distributor = new CREDRewardDistributor(
            address(cred),
            address(news),
            address(staking),
            address(registry),
            owner
        );

        // Transfer CRED ownership to distributor
        cred.transferOwnership(address(distributor));

        // Setup staking
        news.mint(staker, 1000 * 1e18);
        staking.setGovernance(owner);

        vm.stopPrank();

        // Stake tokens
        vm.startPrank(staker);
        news.approve(address(staking), 1000 * 1e18);
        staking.stake(1000 * 1e18);
        vm.stopPrank();
    }

    function testRewardPublishingHighQuality() public {
        vm.prank(owner);
        distributor.rewardPublishing(reporter, 95);

        (
            uint256 earned,
            uint256 publishCount,
            ,
            ,
            uint256 balance
        ) = distributor.getUserRewardStats(reporter);

        assertTrue(earned > 0);
        assertEq(publishCount, 1);
        assertEq(balance, earned);
    }

    function testRewardPublishingBonusForExceptional() public {
        vm.prank(owner);
        distributor.rewardPublishing(reporter, 95);

        uint256 balance1 = cred.balanceOf(reporter);

        // Standard quality
        vm.warp(block.timestamp + 2 days);
        vm.prank(owner);
        distributor.rewardPublishing(reporter, 80);

        uint256 balance2 = cred.balanceOf(reporter);

        // Exceptional should give more than standard
        assertTrue(balance1 > (balance2 - balance1));
    }

    function testRewardVerificationAccurate() public {
        vm.prank(owner);
        distributor.rewardVerification(verifier, true);

        (, , uint256 verifyCount, , uint256 balance) = distributor
            .getUserRewardStats(verifier);

        assertTrue(balance > 0);
        assertEq(verifyCount, 1);
    }

    function testCannotRewardInaccurateVerification() public {
        vm.prank(owner);
        vm.expectRevert("Verification must be accurate for reward");
        distributor.rewardVerification(verifier, false);
    }

    function testClaimStakingRewards() public {
        // Fast forward 1 day
        vm.warp(block.timestamp + 1 days);

        vm.prank(staker);
        distributor.claimStakingRewards();

        uint256 balance = cred.balanceOf(staker);
        assertTrue(balance > 0);
    }

    function testCannotClaimStakingTwiceSameDay() public {
        vm.warp(block.timestamp + 1 days);

        vm.prank(staker);
        distributor.claimStakingRewards();

        vm.prank(staker);
        vm.expectRevert("Already claimed today");
        distributor.claimStakingRewards();
    }

    function testRewardGovernanceParticipation() public {
        vm.prank(owner);
        distributor.rewardGovernanceParticipation(staker);

        (, , , uint256 govCount, uint256 balance) = distributor
            .getUserRewardStats(staker);

        assertEq(govCount, 1);
        assertTrue(balance > 0);
    }

    function testBatchReward() public {
        address[] memory contributors = new address[](3);
        contributors[0] = reporter;
        contributors[1] = verifier;
        contributors[2] = staker;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100 * 1e18;
        amounts[1] = 50 * 1e18;
        amounts[2] = 25 * 1e18;

        string[] memory types = new string[](3);
        types[0] = "Publishing";
        types[1] = "Verification";
        types[2] = "Governance";

        vm.prank(owner);
        distributor.batchReward(contributors, amounts, types);

        assertEq(cred.balanceOf(reporter), 100 * 1e18);
        assertEq(cred.balanceOf(verifier), 50 * 1e18);
        assertEq(cred.balanceOf(staker), 25 * 1e18);
    }

    function testUpdateRewardRates() public {
        vm.startPrank(owner);

        distributor.updatePublishRewardRate(200 * 1e18);
        assertEq(distributor.publishRewardRate(), 200 * 1e18);

        distributor.updateVerificationRewardRate(75 * 1e18);
        assertEq(distributor.verificationRewardRate(), 75 * 1e18);

        vm.stopPrank();
    }

    function testToggleRewards() public {
        vm.startPrank(owner);

        distributor.togglePublishRewards(false);
        assertFalse(distributor.publishRewardsEnabled());

        distributor.toggleVerificationRewards(false);
        assertFalse(distributor.verificationRewardsEnabled());

        vm.stopPrank();
    }

    function testCannotRewardWhenDisabled() public {
        vm.prank(owner);
        distributor.togglePublishRewards(false);

        vm.prank(owner);
        vm.expectRevert("Publishing rewards disabled");
        distributor.rewardPublishing(reporter, 90);
    }

    function testPublishingCooldown() public {
        vm.prank(owner);
        distributor.rewardPublishing(reporter, 90);

        // Try to reward again immediately
        vm.prank(owner);
        vm.expectRevert("Cooldown period active");
        distributor.rewardPublishing(reporter, 90);

        // Fast forward past cooldown
        vm.warp(block.timestamp + 2 days);

        vm.prank(owner);
        distributor.rewardPublishing(reporter, 90);

        // Should succeed
        (, uint256 publishCount, , , ) = distributor.getUserRewardStats(
            reporter
        );
        assertEq(publishCount, 2);
    }
}
