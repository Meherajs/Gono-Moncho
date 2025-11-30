// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SyndicationLicensing
 * @notice Manages content syndication rights and revenue distribution
 * @dev Per whitepaper Section VI: Content Syndication Fees
 *
 * "News organizations, blogs, or aggregators that want to republish news
 * from the ecosystem will pay a small syndication fee"
 *
 * Features:
 * - Licensing for content republishing
 * - Revenue split between journalist, outlet, and platform
 * - Usage tracking and analytics
 * - Tiered pricing based on subscriber count
 */
contract SyndicationLicensing is Ownable {
    // Syndication tiers based on platform size
    enum SubscriberTier {
        SMALL, // < 10k subscribers
        MEDIUM, // 10k - 100k subscribers
        LARGE, // 100k - 1M subscribers
        ENTERPRISE // > 1M subscribers
    }

    // Pricing per tier (in wei, e.g., MATIC)
    mapping(SubscriberTier => uint256) public tierPricing;

    // Revenue split percentages (in basis points, 10000 = 100%)
    uint256 public constant JOURNALIST_SHARE = 6000; // 60%
    uint256 public constant OUTLET_SHARE = 3000; // 30%
    uint256 public constant PLATFORM_SHARE = 1000; // 10%

    struct SyndicationLicense {
        address licensee; // Organization republishing
        bytes32 contentHash; // Article being syndicated
        address journalist; // Original author
        address outlet; // Original publisher
        uint256 fee; // Fee paid
        uint256 startDate;
        uint256 expiryDate;
        SubscriberTier tier;
        bool active;
        uint256 republishCount; // Track usage
    }

    struct ContentRights {
        address journalist;
        address outlet;
        bool exclusiveRights; // If true, only outlet can license
        uint256 minimumFee; // Minimum syndication fee
        bool syndicationAllowed;
        uint256 totalRevenue;
    }

    struct LicenseeProfile {
        string name;
        string website;
        uint256 estimatedSubscribers;
        SubscriberTier tier;
        uint256 activeLicenses;
        uint256 totalSpent;
        bool verified;
    }

    // License ID => License data
    mapping(uint256 => SyndicationLicense) public licenses;
    uint256 public nextLicenseId;

    // Content hash => Rights data
    mapping(bytes32 => ContentRights) public contentRights;

    // Licensee address => Profile
    mapping(address => LicenseeProfile) public licensees;

    // Track revenue per journalist
    mapping(address => uint256) public journalistRevenue;

    // Track revenue per outlet
    mapping(address => uint256) public outletRevenue;

    // Platform treasury address
    address public platformTreasury;

    // Total platform revenue
    uint256 public totalPlatformRevenue;

    // Events
    event LicensePurchased(
        uint256 indexed licenseId,
        address indexed licensee,
        bytes32 indexed contentHash,
        uint256 fee
    );

    event ContentRepublished(
        uint256 indexed licenseId,
        bytes32 indexed contentHash,
        address indexed licensee
    );

    event RevenueDistributed(
        bytes32 indexed contentHash,
        address journalist,
        address outlet,
        uint256 totalFee
    );

    event LicenseeRegistered(
        address indexed licensee,
        string name,
        SubscriberTier tier
    );

    event ContentRightsSet(
        bytes32 indexed contentHash,
        address journalist,
        address outlet
    );

    constructor(
        address _platformTreasury,
        address initialOwner
    ) Ownable(initialOwner) {
        platformTreasury = _platformTreasury;

        // Initialize tier pricing (in wei)
        tierPricing[SubscriberTier.SMALL] = 0.001 ether; // ~$2 per article
        tierPricing[SubscriberTier.MEDIUM] = 0.005 ether; // ~$10 per article
        tierPricing[SubscriberTier.LARGE] = 0.02 ether; // ~$40 per article
        tierPricing[SubscriberTier.ENTERPRISE] = 0.1 ether; // ~$200 per article
    }

    /**
     * @notice Register as a licensee (content syndicator)
     * @param name Organization name
     * @param website Website URL
     * @param estimatedSubscribers Subscriber count
     */
    function registerLicensee(
        string memory name,
        string memory website,
        uint256 estimatedSubscribers
    ) external {
        require(bytes(name).length > 0, "Name required");
        require(
            licensees[msg.sender].tier == SubscriberTier.SMALL &&
                bytes(licensees[msg.sender].name).length == 0,
            "Already registered"
        );

        // Determine tier based on subscribers
        SubscriberTier tier;
        if (estimatedSubscribers < 10000) {
            tier = SubscriberTier.SMALL;
        } else if (estimatedSubscribers < 100000) {
            tier = SubscriberTier.MEDIUM;
        } else if (estimatedSubscribers < 1000000) {
            tier = SubscriberTier.LARGE;
        } else {
            tier = SubscriberTier.ENTERPRISE;
        }

        licensees[msg.sender] = LicenseeProfile({
            name: name,
            website: website,
            estimatedSubscribers: estimatedSubscribers,
            tier: tier,
            activeLicenses: 0,
            totalSpent: 0,
            verified: false
        });

        emit LicenseeRegistered(msg.sender, name, tier);
    }

    /**
     * @notice Set content rights (called by publishing contract)
     * @param contentHash Hash of the content
     * @param journalist Original journalist
     * @param outlet Publishing outlet
     * @param exclusiveRights Whether outlet has exclusive rights
     * @param minimumFee Minimum syndication fee
     */
    function setContentRights(
        bytes32 contentHash,
        address journalist,
        address outlet,
        bool exclusiveRights,
        uint256 minimumFee
    ) external onlyOwner {
        require(journalist != address(0), "Invalid journalist");

        contentRights[contentHash] = ContentRights({
            journalist: journalist,
            outlet: outlet,
            exclusiveRights: exclusiveRights,
            minimumFee: minimumFee,
            syndicationAllowed: true,
            totalRevenue: 0
        });

        emit ContentRightsSet(contentHash, journalist, outlet);
    }

    /**
     * @notice Purchase syndication license
     * @param contentHash Content to syndicate
     * @param durationDays License duration in days
     */
    function purchaseLicense(
        bytes32 contentHash,
        uint256 durationDays
    ) external payable returns (uint256 licenseId) {
        ContentRights storage rights = contentRights[contentHash];
        require(rights.syndicationAllowed, "Syndication not allowed");
        require(rights.journalist != address(0), "Content not found");

        LicenseeProfile storage licensee = licensees[msg.sender];
        require(bytes(licensee.name).length > 0, "Not registered as licensee");

        // Calculate fee based on tier
        uint256 baseFee = tierPricing[licensee.tier];
        uint256 totalFee = baseFee * ((durationDays + 29) / 30); // Round up to months

        // Check minimum fee
        if (rights.minimumFee > 0) {
            require(totalFee >= rights.minimumFee, "Fee below minimum");
        }

        require(msg.value >= totalFee, "Insufficient payment");

        // Create license
        licenseId = nextLicenseId++;

        licenses[licenseId] = SyndicationLicense({
            licensee: msg.sender,
            contentHash: contentHash,
            journalist: rights.journalist,
            outlet: rights.outlet,
            fee: totalFee,
            startDate: block.timestamp,
            expiryDate: block.timestamp + (durationDays * 1 days),
            tier: licensee.tier,
            active: true,
            republishCount: 0
        });

        // Update stats
        licensee.activeLicenses++;
        licensee.totalSpent += totalFee;

        // Distribute revenue
        _distributeRevenue(
            contentHash,
            totalFee,
            rights.journalist,
            rights.outlet
        );

        // Refund excess payment
        if (msg.value > totalFee) {
            payable(msg.sender).transfer(msg.value - totalFee);
        }

        emit LicensePurchased(licenseId, msg.sender, contentHash, totalFee);
        return licenseId;
    }

    /**
     * @notice Record content republication (analytics)
     * @param licenseId License being used
     */
    function recordRepublish(uint256 licenseId) external {
        SyndicationLicense storage license = licenses[licenseId];
        require(license.active, "License not active");
        require(license.licensee == msg.sender, "Not license holder");
        require(block.timestamp <= license.expiryDate, "License expired");

        license.republishCount++;

        emit ContentRepublished(licenseId, license.contentHash, msg.sender);
    }

    /**
     * @notice Check if license is valid
     * @param licenseId License to check
     */
    function isLicenseValid(uint256 licenseId) external view returns (bool) {
        SyndicationLicense memory license = licenses[licenseId];
        return license.active && block.timestamp <= license.expiryDate;
    }

    /**
     * @notice Get content revenue breakdown
     * @param contentHash Content hash
     */
    function getContentRevenue(
        bytes32 contentHash
    )
        external
        view
        returns (uint256 totalRevenue, address journalist, address outlet)
    {
        ContentRights memory rights = contentRights[contentHash];
        return (rights.totalRevenue, rights.journalist, rights.outlet);
    }

    /**
     * @notice Update tier pricing
     * @param tier Tier to update
     * @param newPrice New price in wei
     */
    function updateTierPricing(
        SubscriberTier tier,
        uint256 newPrice
    ) external onlyOwner {
        tierPricing[tier] = newPrice;
    }

    /**
     * @notice Verify licensee (DAO governance)
     * @param licensee Address to verify
     * @param verified Verification status
     */
    function verifyLicensee(
        address licensee,
        bool verified
    ) external onlyOwner {
        require(bytes(licensees[licensee].name).length > 0, "Not registered");
        licensees[licensee].verified = verified;
    }

    /**
     * @notice Withdraw journalist revenue
     */
    function withdrawJournalistRevenue() external {
        uint256 amount = journalistRevenue[msg.sender];
        require(amount > 0, "No revenue to withdraw");

        journalistRevenue[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    /**
     * @notice Withdraw outlet revenue
     */
    function withdrawOutletRevenue() external {
        uint256 amount = outletRevenue[msg.sender];
        require(amount > 0, "No revenue to withdraw");

        outletRevenue[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    /**
     * @notice Withdraw platform revenue
     */
    function withdrawPlatformRevenue() external {
        require(
            msg.sender == platformTreasury || msg.sender == owner(),
            "Not authorized"
        );
        require(totalPlatformRevenue > 0, "No revenue");

        uint256 amount = totalPlatformRevenue;
        totalPlatformRevenue = 0;

        payable(platformTreasury).transfer(amount);
    }

    /**
     * @notice Internal: Distribute syndication revenue
     */
    function _distributeRevenue(
        bytes32 contentHash,
        uint256 totalFee,
        address journalist,
        address outlet
    ) internal {
        // Calculate splits
        uint256 journalistAmount = (totalFee * JOURNALIST_SHARE) / 10000;
        uint256 outletAmount = (totalFee * OUTLET_SHARE) / 10000;
        uint256 platformAmount = (totalFee * PLATFORM_SHARE) / 10000;

        // Update balances
        journalistRevenue[journalist] += journalistAmount;

        if (outlet != address(0)) {
            outletRevenue[outlet] += outletAmount;
        } else {
            // If no outlet, give extra to journalist
            journalistRevenue[journalist] += outletAmount;
        }

        totalPlatformRevenue += platformAmount;

        // Update content revenue
        contentRights[contentHash].totalRevenue += totalFee;

        emit RevenueDistributed(contentHash, journalist, outlet, totalFee);
    }

    /**
     * @notice Update platform treasury address
     */
    function updatePlatformTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), "Invalid address");
        platformTreasury = newTreasury;
    }
}
