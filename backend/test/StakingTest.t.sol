// test/StakingTest.t.sol
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/tokens/NEWS.sol";
import "../src/tokens/CRED.sol";
import "../src/staking/NewsStaking.sol";

contract StakingTest is Test {
    NEWS public news;
    CRED public cred;
    NewsStaking public staking;
    address owner = address(1);
    address user = address(2);
    address governance = address(3);

    function setUp() public {
        news = new NEWS(owner);
        cred = new CRED(owner);
        staking = new NewsStaking(address(news), address(cred), owner);

        // Setup
        vm.prank(owner);
        news.mint(user, 10000 * 1e18);

        vm.prank(owner);
        staking.setGovernance(governance);
    }

    function testStaking() public {
        vm.startPrank(user);
        news.approve(address(staking), 1000);
        staking.stake(1000);

        (uint256 amount, ) = staking.stakes(user);
        assertEq(amount, 1000);
        vm.stopPrank();
    }

    function testSlashing() public {
        // Setup stake
        vm.prank(user);
        news.approve(address(staking), 1000);
        vm.prank(user);
        staking.stake(1000);

        // Slash
        vm.prank(governance);
        staking.slash(user, 500);

        (uint256 newAmount, ) = staking.stakes(user);
        assertEq(newAmount, 500);
        assertEq(news.balanceOf(address(staking)), 500);
    }

    function testNonGovernanceCannotSlash() public {
        vm.prank(user);
        news.approve(address(staking), 1000);
        vm.prank(user);
        staking.stake(1000);

        vm.prank(address(4)); // Random address
        vm.expectRevert("Unauthorized");
        staking.slash(user, 500);
    }

    function testVoteCostCalculation() public {
        assertEq(staking.calculateVoteCost(1), 1);
        assertEq(staking.calculateVoteCost(2), 4);
        assertEq(staking.calculateVoteCost(10), 100);
    }
}
