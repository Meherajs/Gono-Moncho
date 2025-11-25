// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../tokens/NEWS.sol";

/**
 * @title ReporterRegistry
 * @notice Manages reporter registration, verification, and role-based access
 * @dev Implements the reporter verification system described in the Gono Moncho whitepaper
 */
contract ReporterRegistry is Ownable {
    NEWS public immutable newsToken;

    // User roles as defined in the whitepaper
    enum UserRole {
        NONE,
        REPORTER,
        ANALYZER,
        VERIFIER
    }

    // Reporter status for verification process
    enum ReporterStatus {
        NONE,
        PENDING,
        VERIFIED,
        REJECTED,
        SUSPENDED
    }

    struct ReporterProfile {
        UserRole role;
        ReporterStatus status;
        uint256 stakedAmount;
        uint256 registeredAt;
        uint256 verifiedAt;
        string ipfsMetadata; // IPFS hash containing: name, credentials, proof documents
        address verifiedBy;
        uint256 publishedArticles;
        bool isFreeTestAccount; // For testing phase - bypass staking requirement
    }

    // Minimum stake required for different roles (in wei)
    uint256 public constant REPORTER_STAKE_REQUIRED = 100 * 1e18; // 100 NEWS tokens
    uint256 public constant ANALYZER_STAKE_REQUIRED = 50 * 1e18;  // 50 NEWS tokens
    uint256 public constant VERIFIER_STAKE_REQUIRED = 25 * 1e18;  // 25 NEWS tokens

    // Testing mode - allows free registration
    bool public testingMode;

    // Mapping from address to reporter profile
    mapping(address => ReporterProfile) public reporters;

    // List of addresses authorized to verify reporters (initially admins, later DAO)
    mapping(address => bool) public authorizedVerifiers;

    // Events
    event ReporterRegistered(
        address indexed reporter,
        UserRole role,
        string ipfsMetadata
    );
    event ReporterVerified(
        address indexed reporter,
        address indexed verifier,
        bool approved
    );
    event StakeDeposited(address indexed reporter, uint256 amount);
    event StakeWithdrawn(address indexed reporter, uint256 amount);
    event RoleChanged(address indexed user, UserRole oldRole, UserRole newRole);
    event TestingModeChanged(bool enabled);

    modifier onlyVerifier() {
        require(
            authorizedVerifiers[msg.sender] || msg.sender == owner(),
            "Not authorized verifier"
        );
        _;
    }

    modifier onlyVerifiedReporter() {
        require(
            reporters[msg.sender].status == ReporterStatus.VERIFIED,
            "Not a verified reporter"
        );
        _;
    }

    constructor(address _newsToken, address initialOwner) Ownable(initialOwner) {
        newsToken = NEWS(_newsToken);
        testingMode = true; // Start in testing mode
        authorizedVerifiers[initialOwner] = true;
    }

    /**
     * @notice Register as a reporter with credentials
     * @param _ipfsMetadata IPFS hash containing reporter credentials and proof
     * @param _role Desired role (REPORTER, ANALYZER, or VERIFIER)
     */
    function registerReporter(
        string memory _ipfsMetadata,
        UserRole _role
    ) external {
        require(_role != UserRole.NONE, "Invalid role");
        require(
            reporters[msg.sender].status == ReporterStatus.NONE,
            "Already registered"
        );
        require(bytes(_ipfsMetadata).length > 0, "Metadata required");

        reporters[msg.sender] = ReporterProfile({
            role: _role,
            status: ReporterStatus.PENDING,
            stakedAmount: 0,
            registeredAt: block.timestamp,
            verifiedAt: 0,
            ipfsMetadata: _ipfsMetadata,
            verifiedBy: address(0),
            publishedArticles: 0,
            isFreeTestAccount: testingMode // In testing mode, mark as free account
        });

        emit ReporterRegistered(msg.sender, _role, _ipfsMetadata);
    }

    /**
     * @notice Stake NEWS tokens to meet role requirements
     * @param _amount Amount of NEWS tokens to stake
     */
    function stakeTokens(uint256 _amount) external {
        require(
            reporters[msg.sender].status == ReporterStatus.PENDING ||
                reporters[msg.sender].status == ReporterStatus.VERIFIED,
            "Must be registered"
        );

        // Transfer tokens from user to contract
        require(
            newsToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );

        reporters[msg.sender].stakedAmount += _amount;

        emit StakeDeposited(msg.sender, _amount);
    }

    /**
     * @notice Verify a reporter's credentials (admin/DAO only)
     * @param _reporter Address of the reporter to verify
     * @param _approve Whether to approve or reject
     */
    function verifyReporter(address _reporter, bool _approve) external onlyVerifier {
        ReporterProfile storage profile = reporters[_reporter];
        require(
            profile.status == ReporterStatus.PENDING,
            "Reporter not pending verification"
        );

        if (_approve) {
            // Check if testing mode OR sufficient stake
            if (!testingMode) {
                uint256 requiredStake = getRequiredStake(profile.role);
                require(
                    profile.stakedAmount >= requiredStake,
                    "Insufficient stake"
                );
            }

            profile.status = ReporterStatus.VERIFIED;
            profile.verifiedAt = block.timestamp;
            profile.verifiedBy = msg.sender;
        } else {
            profile.status = ReporterStatus.REJECTED;
            
            // Refund stake if rejected
            if (profile.stakedAmount > 0) {
                uint256 refundAmount = profile.stakedAmount;
                profile.stakedAmount = 0;
                require(
                    newsToken.transfer(_reporter, refundAmount),
                    "Refund failed"
                );
            }
        }

        emit ReporterVerified(_reporter, msg.sender, _approve);
    }

    /**
     * @notice Withdraw staked tokens (only if not suspended and maintains minimum)
     * @param _amount Amount to withdraw
     */
    function withdrawStake(uint256 _amount) external {
        ReporterProfile storage profile = reporters[msg.sender];
        require(
            profile.status == ReporterStatus.VERIFIED,
            "Not verified"
        );
        require(
            profile.stakedAmount >= _amount,
            "Insufficient staked amount"
        );

        uint256 requiredStake = getRequiredStake(profile.role);
        uint256 remainingStake = profile.stakedAmount - _amount;

        // In testing mode, allow full withdrawal
        if (!testingMode) {
            require(
                remainingStake >= requiredStake,
                "Would fall below minimum stake"
            );
        }

        profile.stakedAmount = remainingStake;
        require(newsToken.transfer(msg.sender, _amount), "Transfer failed");

        emit StakeWithdrawn(msg.sender, _amount);
    }

    /**
     * @notice Increment published article count (called by Verification contract)
     * @param _reporter Address of the reporter
     */
    function incrementArticleCount(address _reporter) external {
        // TODO: Add access control - only Verification contract should call this
        reporters[_reporter].publishedArticles++;
    }

    /**
     * @notice Check if user can publish news
     * @param _user Address to check
     */
    function canPublish(address _user) external view returns (bool) {
        ReporterProfile memory profile = reporters[_user];
        
        // Must be verified reporter
        if (profile.status != ReporterStatus.VERIFIED) {
            return false;
        }

        // In testing mode, verified reporters can publish for free
        if (testingMode && profile.isFreeTestAccount) {
            return true;
        }

        // Otherwise, must have sufficient stake
        uint256 requiredStake = getRequiredStake(profile.role);
        return profile.stakedAmount >= requiredStake;
    }

    /**
     * @notice Check if user can verify news
     * @param _user Address to check
     */
    function canVerify(address _user) external view returns (bool) {
        ReporterProfile memory profile = reporters[_user];
        
        if (profile.status != ReporterStatus.VERIFIED) {
            return false;
        }

        if (profile.role != UserRole.VERIFIER && profile.role != UserRole.ANALYZER) {
            return false;
        }

        // In testing mode, allow free verification
        if (testingMode && profile.isFreeTestAccount) {
            return true;
        }

        uint256 requiredStake = getRequiredStake(profile.role);
        return profile.stakedAmount >= requiredStake;
    }

    /**
     * @notice Get required stake for a role
     */
    function getRequiredStake(UserRole _role) public pure returns (uint256) {
        if (_role == UserRole.REPORTER) return REPORTER_STAKE_REQUIRED;
        if (_role == UserRole.ANALYZER) return ANALYZER_STAKE_REQUIRED;
        if (_role == UserRole.VERIFIER) return VERIFIER_STAKE_REQUIRED;
        return 0;
    }

    /**
     * @notice Get reporter profile
     */
    function getReporterProfile(
        address _reporter
    )
        external
        view
        returns (
            UserRole role,
            ReporterStatus status,
            uint256 stakedAmount,
            uint256 registeredAt,
            uint256 verifiedAt,
            string memory ipfsMetadata,
            uint256 publishedArticles,
            bool isFreeTestAccount
        )
    {
        ReporterProfile memory profile = reporters[_reporter];
        return (
            profile.role,
            profile.status,
            profile.stakedAmount,
            profile.registeredAt,
            profile.verifiedAt,
            profile.ipfsMetadata,
            profile.publishedArticles,
            profile.isFreeTestAccount
        );
    }

    /**
     * @notice Toggle testing mode (owner only)
     */
    function setTestingMode(bool _enabled) external onlyOwner {
        testingMode = _enabled;
        emit TestingModeChanged(_enabled);
    }

    /**
     * @notice Add authorized verifier (owner only)
     */
    function addVerifier(address _verifier) external onlyOwner {
        authorizedVerifiers[_verifier] = true;
    }

    /**
     * @notice Remove authorized verifier (owner only)
     */
    function removeVerifier(address _verifier) external onlyOwner {
        authorizedVerifiers[_verifier] = false;
    }

    /**
     * @notice Suspend a reporter (governance action)
     */
    function suspendReporter(address _reporter) external onlyOwner {
        require(
            reporters[_reporter].status == ReporterStatus.VERIFIED,
            "Not verified reporter"
        );
        reporters[_reporter].status = ReporterStatus.SUSPENDED;
    }

    /**
     * @notice Reinstate a suspended reporter
     */
    function reinstateReporter(address _reporter) external onlyOwner {
        require(
            reporters[_reporter].status == ReporterStatus.SUSPENDED,
            "Not suspended"
        );
        reporters[_reporter].status = ReporterStatus.VERIFIED;
    }
}
