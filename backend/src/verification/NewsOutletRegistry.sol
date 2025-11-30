// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NewsOutletRegistry
 * @notice Registry for news organizations to integrate into Gono Moncho ecosystem
 * @dev Enables news outlets to stake, register journalists, and publish via API
 *
 * Per whitepaper Section III.A:
 * "Decentralized API: News outlets can integrate the framework into their
 * existing systems, transferring the storage of news onto the Blockchain
 * without disrupting their workflows."
 */
contract NewsOutletRegistry is Ownable {
    // Minimum stake required for outlet registration
    uint256 public constant MINIMUM_OUTLET_STAKE = 10000 * 1e18; // 10,000 NEWS

    // Organization verification status
    enum VerificationStatus {
        PENDING, // Submitted but not verified
        VERIFIED, // Verified by DAO
        SUSPENDED, // Temporarily suspended
        BANNED // Permanently banned
    }

    // Organization tier based on reputation
    enum OrganizationTier {
        BRONZE, // New organizations
        SILVER, // Established reputation
        GOLD, // Highly trusted
        PLATINUM // Top-tier organizations
    }

    struct NewsOutlet {
        string name;
        string legalEntityName;
        string registrationNumber; // Business registration
        string country;
        string website;
        address treasuryAddress;
        uint256 stakeAmount;
        uint256 registrationDate;
        VerificationStatus status;
        OrganizationTier tier;
        uint256 affiliatedJournalists;
        uint256 articlesPublished;
        uint256 credibilityScore; // 0-10000 (2 decimal precision)
        string apiKey; // Hashed API key for integration
        bool apiEnabled;
    }

    struct AffiliatedJournalist {
        address journalistAddress;
        string role; // "Editor", "Reporter", "Photographer", etc.
        uint256 affiliatedSince;
        bool active;
        uint256 articlesContributed;
    }

    // Outlet address => NewsOutlet data
    mapping(address => NewsOutlet) public outlets;

    // Outlet address => journalist address => AffiliatedJournalist
    mapping(address => mapping(address => AffiliatedJournalist))
        public affiliations;

    // Outlet address => journalist addresses array
    mapping(address => address[]) public outletJournalists;

    // Journalist address => outlet addresses array
    mapping(address => address[]) public journalistOutlets;

    // Track all registered outlets
    address[] public allOutlets;

    // API key hash => outlet address
    mapping(bytes32 => address) public apiKeyToOutlet;

    // Track staked amounts
    mapping(address => uint256) public stakedAmounts;

    // Events
    event OutletRegistered(
        address indexed outlet,
        string name,
        uint256 stakeAmount
    );

    event OutletVerified(address indexed outlet, VerificationStatus status);
    event JournalistAffiliated(
        address indexed outlet,
        address indexed journalist,
        string role
    );
    event JournalistRemoved(address indexed outlet, address indexed journalist);
    event StakeIncreased(address indexed outlet, uint256 newAmount);
    event StakeWithdrawn(address indexed outlet, uint256 amount);
    event APIKeyGenerated(address indexed outlet);
    event TierUpgraded(address indexed outlet, OrganizationTier newTier);
    event ArticlePublished(
        address indexed outlet,
        address indexed journalist,
        bytes32 articleHash
    );

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @notice Register a news organization
     * @param name Public-facing name of the organization
     * @param legalEntityName Legal business name
     * @param registrationNumber Business registration number
     * @param country Country of incorporation
     * @param website Official website URL
     * @param treasuryAddress Wallet for receiving payments/rewards
     */
    function registerOutlet(
        string memory name,
        string memory legalEntityName,
        string memory registrationNumber,
        string memory country,
        string memory website,
        address treasuryAddress
    ) external payable {
        require(
            outlets[msg.sender].registrationDate == 0,
            "Already registered"
        );
        require(msg.value >= MINIMUM_OUTLET_STAKE, "Insufficient stake");
        require(treasuryAddress != address(0), "Invalid treasury");
        require(bytes(name).length > 0, "Name required");

        outlets[msg.sender] = NewsOutlet({
            name: name,
            legalEntityName: legalEntityName,
            registrationNumber: registrationNumber,
            country: country,
            website: website,
            treasuryAddress: treasuryAddress,
            stakeAmount: msg.value,
            registrationDate: block.timestamp,
            status: VerificationStatus.PENDING,
            tier: OrganizationTier.BRONZE,
            affiliatedJournalists: 0,
            articlesPublished: 0,
            credibilityScore: 5000, // Start at 50.00%
            apiKey: "",
            apiEnabled: false
        });

        stakedAmounts[msg.sender] = msg.value;
        allOutlets.push(msg.sender);

        emit OutletRegistered(msg.sender, name, msg.value);
    }

    /**
     * @notice Verify a news organization (DAO governance)
     * @param outlet Address of the outlet to verify
     * @param approved Whether to approve or reject
     */
    function verifyOutlet(address outlet, bool approved) external onlyOwner {
        require(outlets[outlet].registrationDate > 0, "Outlet not registered");

        if (approved) {
            outlets[outlet].status = VerificationStatus.VERIFIED;
            emit OutletVerified(outlet, VerificationStatus.VERIFIED);
        } else {
            outlets[outlet].status = VerificationStatus.BANNED;
            emit OutletVerified(outlet, VerificationStatus.BANNED);
        }
    }

    /**
     * @notice Add journalist to organization
     * @param journalist Address of the journalist
     * @param role Role within organization
     */
    function affiliateJournalist(
        address journalist,
        string memory role
    ) external {
        require(
            outlets[msg.sender].status == VerificationStatus.VERIFIED,
            "Outlet not verified"
        );
        require(journalist != address(0), "Invalid journalist");
        require(
            !affiliations[msg.sender][journalist].active,
            "Already affiliated"
        );

        affiliations[msg.sender][journalist] = AffiliatedJournalist({
            journalistAddress: journalist,
            role: role,
            affiliatedSince: block.timestamp,
            active: true,
            articlesContributed: 0
        });

        outletJournalists[msg.sender].push(journalist);
        journalistOutlets[journalist].push(msg.sender);
        outlets[msg.sender].affiliatedJournalists++;

        emit JournalistAffiliated(msg.sender, journalist, role);
    }

    /**
     * @notice Remove journalist from organization
     * @param journalist Address to remove
     */
    function removeJournalist(address journalist) external {
        require(affiliations[msg.sender][journalist].active, "Not affiliated");

        affiliations[msg.sender][journalist].active = false;
        outlets[msg.sender].affiliatedJournalists--;

        emit JournalistRemoved(msg.sender, journalist);
    }

    /**
     * @notice Generate API key for outlet integration
     */
    function generateAPIKey() external {
        require(
            outlets[msg.sender].status == VerificationStatus.VERIFIED,
            "Not verified"
        );

        // Generate unique API key hash
        bytes32 keyHash = keccak256(
            abi.encodePacked(msg.sender, block.timestamp, block.prevrandao)
        );

        string memory apiKey = bytes32ToString(keyHash);
        outlets[msg.sender].apiKey = apiKey;
        outlets[msg.sender].apiEnabled = true;
        apiKeyToOutlet[keyHash] = msg.sender;

        emit APIKeyGenerated(msg.sender);
    }

    /**
     * @notice Record article publication (called by publishing contract)
     * @param journalist Journalist who published
     * @param articleHash Hash of the article
     */
    function recordPublication(
        address journalist,
        bytes32 articleHash
    ) external {
        require(
            outlets[msg.sender].status == VerificationStatus.VERIFIED,
            "Not authorized"
        );

        outlets[msg.sender].articlesPublished++;

        if (affiliations[msg.sender][journalist].active) {
            affiliations[msg.sender][journalist].articlesContributed++;
        }

        emit ArticlePublished(msg.sender, journalist, articleHash);
    }

    /**
     * @notice Increase stake amount
     */
    function increaseStake() external payable {
        require(outlets[msg.sender].registrationDate > 0, "Not registered");
        require(msg.value > 0, "No value sent");

        outlets[msg.sender].stakeAmount += msg.value;
        stakedAmounts[msg.sender] += msg.value;

        emit StakeIncreased(msg.sender, outlets[msg.sender].stakeAmount);
    }

    /**
     * @notice Withdraw stake (only if not verified or after suspension period)
     */
    function withdrawStake(uint256 amount) external {
        require(
            outlets[msg.sender].stakeAmount >= amount,
            "Insufficient stake"
        );
        require(
            outlets[msg.sender].status == VerificationStatus.PENDING ||
                outlets[msg.sender].status == VerificationStatus.BANNED,
            "Cannot withdraw while verified"
        );

        outlets[msg.sender].stakeAmount -= amount;
        stakedAmounts[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);

        emit StakeWithdrawn(msg.sender, amount);
    }

    /**
     * @notice Update credibility score (called by verification contract)
     * @param outlet Outlet address
     * @param newScore New credibility score (0-10000)
     */
    function updateCredibilityScore(
        address outlet,
        uint256 newScore
    ) external onlyOwner {
        require(newScore <= 10000, "Invalid score");
        outlets[outlet].credibilityScore = newScore;

        // Auto-upgrade tier based on credibility
        if (newScore >= 9000) {
            outlets[outlet].tier = OrganizationTier.PLATINUM;
        } else if (newScore >= 8000) {
            outlets[outlet].tier = OrganizationTier.GOLD;
        } else if (newScore >= 7000) {
            outlets[outlet].tier = OrganizationTier.SILVER;
        }
    }

    /**
     * @notice Check if journalist is affiliated with outlet
     */
    function isAffiliatedJournalist(
        address outlet,
        address journalist
    ) external view returns (bool) {
        return affiliations[outlet][journalist].active;
    }

    /**
     * @notice Get all journalists for an outlet
     */
    function getOutletJournalists(
        address outlet
    ) external view returns (address[] memory) {
        return outletJournalists[outlet];
    }

    /**
     * @notice Get all outlets for a journalist
     */
    function getJournalistOutlets(
        address journalist
    ) external view returns (address[] memory) {
        return journalistOutlets[journalist];
    }

    /**
     * @notice Get total registered outlets
     */
    function getTotalOutlets() external view returns (uint256) {
        return allOutlets.length;
    }

    /**
     * @notice Convert bytes32 to string
     */
    function bytes32ToString(
        bytes32 _bytes32
    ) internal pure returns (string memory) {
        bytes memory bytesArray = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            uint8 value = uint8(_bytes32[i]);
            bytesArray[i * 2] = bytes1(uint8ToChar(value / 16));
            bytesArray[i * 2 + 1] = bytes1(uint8ToChar(value % 16));
        }
        return string(bytesArray);
    }

    function uint8ToChar(uint8 value) internal pure returns (uint8) {
        if (value < 10) {
            return 0x30 + value;
        }
        return 0x61 + value - 10;
    }
}
