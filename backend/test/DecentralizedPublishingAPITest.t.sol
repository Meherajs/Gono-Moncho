// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/external/DecentralizedPublishingAPI.sol";

contract DecentralizedPublishingAPITest is Test {
    DecentralizedPublishingAPI public api;

    address public owner = address(1);
    address public outlet1 = address(2);
    address public outlet2 = address(3);
    address public journalist1 = address(4);

    function setUp() public {
        vm.prank(owner);
        api = new DecentralizedPublishingAPI(owner);
    }

    function testGenerateAPIKey() public {
        vm.prank(owner);
        api.registerOutlet(outlet1, "The Daily News", false);

        vm.prank(owner);
        string memory apiKey = api.generateAPIKey(outlet1);

        assertTrue(bytes(apiKey).length > 0);
        assertTrue(api.validateAPIKey(outlet1, apiKey));
    }

    function testSubmitArticle() public {
        // Setup outlet with API key
        vm.prank(owner);
        api.registerOutlet(outlet1, "The Daily News", false);

        vm.prank(owner);
        string memory apiKey = api.generateAPIKey(outlet1);

        // Submit article
        vm.prank(outlet1);
        uint256 requestId = api.submitArticle(
            apiKey,
            journalist1,
            "Breaking News",
            "https://arweave.net/article123",
            "POLITICS"
        );

        assertGt(requestId, 0);
    }

    function testBatchSubmitArticles() public {
        vm.prank(owner);
        api.registerOutlet(outlet1, "The Daily News", false);

        vm.prank(owner);
        string memory apiKey = api.generateAPIKey(outlet1);

        // Prepare batch data
        address[] memory authors = new address[](3);
        authors[0] = journalist1;
        authors[1] = journalist1;
        authors[2] = journalist1;

        string[] memory titles = new string[](3);
        titles[0] = "Article 1";
        titles[1] = "Article 2";
        titles[2] = "Article 3";

        string[] memory contentHashes = new string[](3);
        contentHashes[0] = "hash1";
        contentHashes[1] = "hash2";
        contentHashes[2] = "hash3";

        string[] memory categories = new string[](3);
        categories[0] = "POLITICS";
        categories[1] = "SPORTS";
        categories[2] = "TECHNOLOGY";

        vm.prank(outlet1);
        uint256[] memory requestIds = api.batchSubmitArticles(
            apiKey,
            authors,
            titles,
            contentHashes,
            categories
        );

        assertEq(requestIds.length, 3);
    }

    function testRateLimitDefault() public {
        vm.prank(owner);
        api.registerOutlet(outlet1, "The Daily News", false);

        vm.prank(owner);
        string memory apiKey = api.generateAPIKey(outlet1);

        // Submit 100 articles (daily limit)
        for (uint256 i = 0; i < 100; i++) {
            vm.prank(outlet1);
            api.submitArticle(
                apiKey,
                journalist1,
                "Article",
                "hash",
                "POLITICS"
            );
        }

        // 101st should fail
        vm.prank(outlet1);
        vm.expectRevert("Rate limit exceeded");
        api.submitArticle(
            apiKey,
            journalist1,
            "Article 101",
            "hash101",
            "POLITICS"
        );
    }

    function testRateLimitPremium() public {
        vm.prank(owner);
        api.registerOutlet(outlet1, "Premium Outlet", true); // Premium tier

        vm.prank(owner);
        string memory apiKey = api.generateAPIKey(outlet1);

        // Should be able to submit 1000 articles
        for (uint256 i = 0; i < 150; i++) {
            vm.prank(outlet1);
            api.submitArticle(
                apiKey,
                journalist1,
                "Article",
                "hash",
                "POLITICS"
            );
        }

        (uint256 used, ) = api.getRateLimitStatus(outlet1);
        assertEq(used, 150);
    }

    function testProcessPublishRequest() public {
        vm.prank(owner);
        api.registerOutlet(outlet1, "The Daily News", false);

        vm.prank(owner);
        string memory apiKey = api.generateAPIKey(outlet1);

        vm.prank(outlet1);
        uint256 requestId = api.submitArticle(
            apiKey,
            journalist1,
            "Breaking News",
            "https://arweave.net/article123",
            "POLITICS"
        );

        vm.prank(owner);
        api.processPublishRequest(requestId, true);

        (, , , , , bool processed, bool approved) = api.publishRequests(
            requestId
        );
        assertTrue(processed);
        assertTrue(approved);
    }

    function testAutoApproveForVerifiedOutlets() public {
        vm.prank(owner);
        api.registerOutlet(outlet1, "Verified Outlet", true);

        vm.prank(owner);
        api.setOutletVerified(outlet1, true);

        vm.prank(owner);
        string memory apiKey = api.generateAPIKey(outlet1);

        vm.prank(outlet1);
        uint256 requestId = api.submitArticle(
            apiKey,
            journalist1,
            "Breaking News",
            "https://arweave.net/article123",
            "POLITICS"
        );

        (, , , , , bool processed, bool approved) = api.publishRequests(
            requestId
        );
        assertTrue(processed);
        assertTrue(approved);
    }

    function testInvalidCategory() public {
        vm.prank(owner);
        api.registerOutlet(outlet1, "The Daily News", false);

        vm.prank(owner);
        string memory apiKey = api.generateAPIKey(outlet1);

        vm.prank(outlet1);
        vm.expectRevert("Invalid category");
        api.submitArticle(
            apiKey,
            journalist1,
            "Article",
            "hash",
            "INVALID_CATEGORY"
        );
    }

    function testRevokeAPIKey() public {
        vm.prank(owner);
        api.registerOutlet(outlet1, "The Daily News", false);

        vm.prank(owner);
        string memory apiKey = api.generateAPIKey(outlet1);

        vm.prank(owner);
        api.revokeAPIKey(outlet1);

        assertFalse(api.validateAPIKey(outlet1, apiKey));
    }
}
