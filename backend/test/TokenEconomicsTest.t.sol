// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/tokens/TokenEconomics.sol";
import "../src/tokens/NEWS.sol";

contract TokenEconomicsTest is Test {
    TokenEconomics public tokenEconomics;
    NEWS public newsToken;

    address public owner = address(1);
    address public treasury = address(2);
    address public syndicator = address(3);
    address public subscriber = address(4);

    function setUp() public {
        vm.startPrank(owner);

        // Deploy NEWS token
        newsToken = new NEWS(owner);

        // Deploy TokenEconomics
        tokenEconomics = new TokenEconomics(
            address(newsToken),
            treasury,
            owner
        );

        // Give contract permission to burn tokens
        newsToken.transferOwnership(address(tokenEconomics));

        vm.stopPrank();

        // Fund test accounts
        vm.deal(syndicator, 10 ether);
        vm.deal(subscriber, 10 ether);
    }

    function testCollectSyndicationRevenue() public {
        uint256 amount = 1 ether;

        vm.prank(syndicator);
        tokenEconomics.collectSyndicationRevenue{value: amount}(amount);

        (uint256 revenue, , ) = tokenEconomics.getStats();
        assertEq(revenue, amount);
    }

    function testCollectAnalyticsRevenue() public {
        uint256 amount = 0.5 ether;

        vm.prank(subscriber);
        tokenEconomics.collectAnalyticsRevenue{value: amount}(amount);

        (uint256 revenue, , ) = tokenEconomics.getStats();
        assertEq(revenue, amount);
    }

    function testRevenueAccumulation() public {
        vm.prank(syndicator);
        tokenEconomics.collectSyndicationRevenue{value: 1 ether}(1 ether);

        vm.prank(subscriber);
        tokenEconomics.collectAnalyticsRevenue{value: 0.5 ether}(0.5 ether);

        (uint256 revenue, , ) = tokenEconomics.getStats();
        assertEq(revenue, 1.5 ether);
    }

    function testUpdateFees() public {
        vm.startPrank(owner);

        tokenEconomics.updateSyndicationFee(600); // 6%
        assertEq(tokenEconomics.contentSyndicationFee(), 600);

        tokenEconomics.updateAnalyticsFee(1200); // 12%
        assertEq(tokenEconomics.premiumAnalyticsFee(), 1200);

        vm.stopPrank();
    }

    function testCannotSetFeeTooHigh() public {
        vm.prank(owner);
        vm.expectRevert("Fee too high");
        tokenEconomics.updateSyndicationFee(1100); // 11%, max is 10%
    }

    function testUpdateTreasury() public {
        address newTreasury = address(5);

        vm.prank(owner);
        tokenEconomics.updateTreasury(newTreasury);

        assertEq(tokenEconomics.treasuryAddress(), newTreasury);
    }

    function testCannotSetZeroTreasury() public {
        vm.prank(owner);
        vm.expectRevert("Invalid address");
        tokenEconomics.updateTreasury(address(0));
    }

    function testReceiveDirectPayment() public {
        uint256 amount = 2 ether;

        vm.prank(syndicator);
        (bool success, ) = address(tokenEconomics).call{value: amount}("");
        require(success, "Transfer failed");

        (uint256 revenue, , ) = tokenEconomics.getStats();
        assertEq(revenue, amount);
    }

    function testOnlyOwnerCanUpdateFees() public {
        vm.prank(syndicator);
        vm.expectRevert();
        tokenEconomics.updateSyndicationFee(600);
    }
}
