// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/verification/NewsOutletRegistry.sol";

contract NewsOutletRegistryTest is Test {
    NewsOutletRegistry public registry;

    address public owner = address(1);
    address public outlet1 = address(2);
    address public outlet2 = address(3);
    address public journalist1 = address(4);
    address public journalist2 = address(5);
    address public treasury = address(6);

    function setUp() public {
        vm.prank(owner);
        registry = new NewsOutletRegistry(owner);

        // Fund test accounts
        vm.deal(outlet1, 100 ether);
        vm.deal(outlet2, 100 ether);
    }

    function testRegisterOutlet() public {
        vm.prank(outlet1);
        registry.registerOutlet{value: 10000 ether}(
            "The Daily News",
            "Daily News Corp Ltd",
            "REG123456",
            "United States",
            "https://dailynews.com",
            treasury
        );

        (
            string memory name,
            ,
            ,
            ,
            ,
            ,
            uint256 stakeAmount,
            ,
            ,
            ,
            ,
            ,

        ) = registry.outlets(outlet1);

        assertEq(name, "The Daily News");
        assertEq(stakeAmount, 10000 ether);
    }

    function testCannotRegisterTwice() public {
        vm.startPrank(outlet1);
        registry.registerOutlet{value: 10000 ether}(
            "The Daily News",
            "Daily News Corp Ltd",
            "REG123456",
            "United States",
            "https://dailynews.com",
            treasury
        );

        vm.expectRevert("Already registered");
        registry.registerOutlet{value: 10000 ether}(
            "Another Name",
            "Another Corp",
            "REG789",
            "Canada",
            "https://other.com",
            treasury
        );
        vm.stopPrank();
    }

    function testVerifyOutlet() public {
        vm.prank(outlet1);
        registry.registerOutlet{value: 10000 ether}(
            "The Daily News",
            "Daily News Corp Ltd",
            "REG123456",
            "United States",
            "https://dailynews.com",
            treasury
        );

        vm.prank(owner);
        registry.verifyOutlet(outlet1, true);

        (, , , , , , , uint8 status, , , , , ) = registry.outlets(outlet1);
        assertEq(status, 1); // VERIFIED
    }

    function testAffiliateJournalist() public {
        // Register and verify outlet
        vm.prank(outlet1);
        registry.registerOutlet{value: 10000 ether}(
            "The Daily News",
            "Daily News Corp Ltd",
            "REG123456",
            "United States",
            "https://dailynews.com",
            treasury
        );

        vm.prank(owner);
        registry.verifyOutlet(outlet1, true);

        // Affiliate journalist
        vm.prank(outlet1);
        registry.affiliateJournalist(journalist1, "Senior Reporter");

        assertTrue(registry.isAffiliatedJournalist(outlet1, journalist1));
    }

    function testRemoveJournalist() public {
        // Setup: register, verify, affiliate
        vm.prank(outlet1);
        registry.registerOutlet{value: 10000 ether}(
            "The Daily News",
            "Daily News Corp Ltd",
            "REG123456",
            "United States",
            "https://dailynews.com",
            treasury
        );

        vm.prank(owner);
        registry.verifyOutlet(outlet1, true);

        vm.prank(outlet1);
        registry.affiliateJournalist(journalist1, "Senior Reporter");

        // Remove journalist
        vm.prank(outlet1);
        registry.removeJournalist(journalist1);

        assertFalse(registry.isAffiliatedJournalist(outlet1, journalist1));
    }

    function testGenerateAPIKey() public {
        vm.prank(outlet1);
        registry.registerOutlet{value: 10000 ether}(
            "The Daily News",
            "Daily News Corp Ltd",
            "REG123456",
            "United States",
            "https://dailynews.com",
            treasury
        );

        vm.prank(owner);
        registry.verifyOutlet(outlet1, true);

        vm.prank(outlet1);
        registry.generateAPIKey();

        (, , , , , , , , , , , string memory apiKey, bool apiEnabled) = registry
            .outlets(outlet1);
        assertTrue(bytes(apiKey).length > 0);
        assertTrue(apiEnabled);
    }

    function testIncreaseStake() public {
        vm.prank(outlet1);
        registry.registerOutlet{value: 10000 ether}(
            "The Daily News",
            "Daily News Corp Ltd",
            "REG123456",
            "United States",
            "https://dailynews.com",
            treasury
        );

        vm.prank(outlet1);
        registry.increaseStake{value: 5000 ether}();

        (, , , , , , uint256 stakeAmount, , , , , ) = registry.outlets(outlet1);
        assertEq(stakeAmount, 15000 ether);
    }
}
