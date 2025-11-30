// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DecentralizedPublishingAPI
 * @notice API framework for news outlets to publish via their existing systems
 * @dev Per whitepaper Section III.A:
 * "News outlets can integrate the framework into their existing systems,
 * transferring the storage of news onto the Blockchain without disrupting workflows."
 *
 * Features:
 * - REST-like API interaction via smart contract
 * - Rate limiting per organization
 * - Content validation
 * - Automatic Arweave storage integration
 * - Batch publishing support
 */
contract DecentralizedPublishingAPI is Ownable {
    // Rate limits
    uint256 public constant DEFAULT_DAILY_LIMIT = 100; // 100 articles/day
    uint256 public constant PREMIUM_DAILY_LIMIT = 1000; // 1000 articles/day for premium orgs

    struct APICredentials {
        bytes32 apiKeyHash;
        bool active;
        uint256 createdAt;
        uint256 lastUsed;
        uint256 requestCount;
        uint256 dailyLimit;
    }

    struct PublishRequest {
        address outlet;
        address journalist;
        bytes32 contentHash;
        string arweaveHash;
        string category;
        uint256 timestamp;
        bool processed;
        bool approved;
    }

    struct RateLimitData {
        uint256 requestsToday;
        uint256 lastResetTime;
    }

    // Outlet address => API credentials
    mapping(address => APICredentials) public credentials;

    // API key hash => outlet address
    mapping(bytes32 => address) public apiKeyToOutlet;

    // Request ID => PublishRequest
    mapping(uint256 => PublishRequest) public publishRequests;
    uint256 public nextRequestId;

    // Rate limiting: outlet => date => count
    mapping(address => RateLimitData) public rateLimits;

    // Whitelist of allowed content categories
    mapping(string => bool) public allowedCategories;

    // Track publications per outlet
    mapping(address => uint256) public outletPublicationCount;

    // Track publications per journalist
    mapping(address => uint256) public journalistPublicationCount;

    // Events
    event APIKeyCreated(address indexed outlet, bytes32 keyHash);
    event APIKeyRevoked(address indexed outlet);
    event PublishRequestCreated(
        uint256 indexed requestId,
        address indexed outlet,
        bytes32 contentHash
    );
    event PublishRequestProcessed(uint256 indexed requestId, bool approved);
    event ArticlePublished(
        address indexed outlet,
        address indexed journalist,
        bytes32 contentHash,
        string arweaveHash
    );
    event RateLimitExceeded(address indexed outlet, uint256 limit);
    event CategoryAdded(string category);

    constructor(address initialOwner) Ownable(initialOwner) {
        // Initialize default categories
        allowedCategories["Politics"] = true;
        allowedCategories["Economy"] = true;
        allowedCategories["Technology"] = true;
        allowedCategories["Science"] = true;
        allowedCategories["Health"] = true;
        allowedCategories["Sports"] = true;
        allowedCategories["Entertainment"] = true;
        allowedCategories["Breaking"] = true;
    }

    /**
     * @notice Generate API credentials for outlet
     * @param outlet Address of the news outlet
     * @param isPremium Whether outlet has premium tier
     */
    function generateAPIKey(
        address outlet,
        bool isPremium
    ) external onlyOwner returns (bytes32) {
        require(outlet != address(0), "Invalid outlet");
        require(!credentials[outlet].active, "API key already exists");

        // Generate unique API key hash
        bytes32 keyHash = keccak256(
            abi.encodePacked(outlet, block.timestamp, block.prevrandao)
        );

        credentials[outlet] = APICredentials({
            apiKeyHash: keyHash,
            active: true,
            createdAt: block.timestamp,
            lastUsed: 0,
            requestCount: 0,
            dailyLimit: isPremium ? PREMIUM_DAILY_LIMIT : DEFAULT_DAILY_LIMIT
        });

        apiKeyToOutlet[keyHash] = outlet;

        emit APIKeyCreated(outlet, keyHash);
        return keyHash;
    }

    /**
     * @notice Submit article for publishing via API
     * @param apiKeyHash Hash of API key
     * @param journalist Journalist who wrote the article
     * @param contentHash Hash of article content
     * @param arweaveHash Arweave storage hash
     * @param category Article category
     */
    function submitArticle(
        bytes32 apiKeyHash,
        address journalist,
        bytes32 contentHash,
        string memory arweaveHash,
        string memory category
    ) external returns (uint256 requestId) {
        // Verify API key
        address outlet = apiKeyToOutlet[apiKeyHash];
        require(outlet != address(0), "Invalid API key");
        require(credentials[outlet].active, "API key inactive");

        // Check rate limits
        require(_checkRateLimit(outlet), "Rate limit exceeded");

        // Validate category
        require(allowedCategories[category], "Invalid category");

        // Validate inputs
        require(journalist != address(0), "Invalid journalist");
        require(contentHash != bytes32(0), "Invalid content hash");
        require(bytes(arweaveHash).length > 0, "Arweave hash required");

        // Create publish request
        requestId = nextRequestId++;

        publishRequests[requestId] = PublishRequest({
            outlet: outlet,
            journalist: journalist,
            contentHash: contentHash,
            arweaveHash: arweaveHash,
            category: category,
            timestamp: block.timestamp,
            processed: false,
            approved: false
        });

        // Update credentials
        credentials[outlet].lastUsed = block.timestamp;
        credentials[outlet].requestCount++;

        // Update rate limit
        _incrementRateLimit(outlet);

        emit PublishRequestCreated(requestId, outlet, contentHash);
        return requestId;
    }

    /**
     * @notice Process publish request (auto-approve for verified outlets)
     * @param requestId ID of the publish request
     * @param approve Whether to approve the request
     */
    function processPublishRequest(
        uint256 requestId,
        bool approve
    ) external onlyOwner {
        PublishRequest storage request = publishRequests[requestId];
        require(!request.processed, "Already processed");

        request.processed = true;
        request.approved = approve;

        if (approve) {
            // Record publication
            outletPublicationCount[request.outlet]++;
            journalistPublicationCount[request.journalist]++;

            emit ArticlePublished(
                request.outlet,
                request.journalist,
                request.contentHash,
                request.arweaveHash
            );
        }

        emit PublishRequestProcessed(requestId, approve);
    }

    /**
     * @notice Batch submit multiple articles
     * @param apiKeyHash Hash of API key
     * @param journalists Array of journalist addresses
     * @param contentHashes Array of content hashes
     * @param arweaveHashes Array of Arweave hashes
     * @param categories Array of categories
     */
    function batchSubmitArticles(
        bytes32 apiKeyHash,
        address[] memory journalists,
        bytes32[] memory contentHashes,
        string[] memory arweaveHashes,
        string[] memory categories
    ) external returns (uint256[] memory requestIds) {
        require(
            journalists.length == contentHashes.length &&
                contentHashes.length == arweaveHashes.length &&
                arweaveHashes.length == categories.length,
            "Array length mismatch"
        );

        address outlet = apiKeyToOutlet[apiKeyHash];
        require(outlet != address(0), "Invalid API key");
        require(credentials[outlet].active, "API key inactive");

        // Check if batch would exceed rate limit
        RateLimitData storage rateLimit = rateLimits[outlet];
        _resetRateLimitIfNeeded(outlet);

        require(
            rateLimit.requestsToday + journalists.length <=
                credentials[outlet].dailyLimit,
            "Batch would exceed rate limit"
        );

        requestIds = new uint256[](journalists.length);

        for (uint256 i = 0; i < journalists.length; i++) {
            requestIds[i] = this.submitArticle(
                apiKeyHash,
                journalists[i],
                contentHashes[i],
                arweaveHashes[i],
                categories[i]
            );
        }

        return requestIds;
    }

    /**
     * @notice Revoke API key
     * @param outlet Outlet to revoke
     */
    function revokeAPIKey(address outlet) external onlyOwner {
        require(credentials[outlet].active, "API key not active");

        credentials[outlet].active = false;

        emit APIKeyRevoked(outlet);
    }

    /**
     * @notice Add allowed category
     * @param category Category name
     */
    function addCategory(string memory category) external onlyOwner {
        allowedCategories[category] = true;
        emit CategoryAdded(category);
    }

    /**
     * @notice Update daily limit for outlet
     * @param outlet Outlet address
     * @param newLimit New daily limit
     */
    function updateDailyLimit(
        address outlet,
        uint256 newLimit
    ) external onlyOwner {
        require(credentials[outlet].active, "API key not active");
        credentials[outlet].dailyLimit = newLimit;
    }

    /**
     * @notice Get request details
     */
    function getRequest(
        uint256 requestId
    )
        external
        view
        returns (
            address outlet,
            address journalist,
            bytes32 contentHash,
            string memory arweaveHash,
            string memory category,
            uint256 timestamp,
            bool processed,
            bool approved
        )
    {
        PublishRequest memory request = publishRequests[requestId];
        return (
            request.outlet,
            request.journalist,
            request.contentHash,
            request.arweaveHash,
            request.category,
            request.timestamp,
            request.processed,
            request.approved
        );
    }

    /**
     * @notice Get outlet's current rate limit status
     */
    function getRateLimitStatus(
        address outlet
    )
        external
        view
        returns (uint256 requestsToday, uint256 limit, uint256 remaining)
    {
        RateLimitData memory rateLimit = rateLimits[outlet];
        uint256 dailyLimit = credentials[outlet].dailyLimit;

        // Check if should reset
        if (block.timestamp >= rateLimit.lastResetTime + 1 days) {
            requestsToday = 0;
        } else {
            requestsToday = rateLimit.requestsToday;
        }

        remaining = dailyLimit > requestsToday ? dailyLimit - requestsToday : 0;

        return (requestsToday, dailyLimit, remaining);
    }

    /**
     * @notice Internal: Check rate limit
     */
    function _checkRateLimit(address outlet) internal returns (bool) {
        RateLimitData storage rateLimit = rateLimits[outlet];

        _resetRateLimitIfNeeded(outlet);

        if (rateLimit.requestsToday >= credentials[outlet].dailyLimit) {
            emit RateLimitExceeded(outlet, credentials[outlet].dailyLimit);
            return false;
        }

        return true;
    }

    /**
     * @notice Internal: Increment rate limit counter
     */
    function _incrementRateLimit(address outlet) internal {
        RateLimitData storage rateLimit = rateLimits[outlet];
        rateLimit.requestsToday++;
    }

    /**
     * @notice Internal: Reset rate limit if day has passed
     */
    function _resetRateLimitIfNeeded(address outlet) internal {
        RateLimitData storage rateLimit = rateLimits[outlet];

        if (block.timestamp >= rateLimit.lastResetTime + 1 days) {
            rateLimit.requestsToday = 0;
            rateLimit.lastResetTime = block.timestamp;
        } else if (rateLimit.lastResetTime == 0) {
            rateLimit.lastResetTime = block.timestamp;
        }
    }
}
