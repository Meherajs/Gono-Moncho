// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../tokens/CRED.sol";
import "../tokens/NEWS.sol";
import "../staking/NewsStaking.sol";
import "../verification/ReporterRegistry.sol";

/**
 * @title CREDRewardDistributor
 * @notice Automated CRED reputation token distribution system
 * @dev Rewards contributors based on quality journalism, accurate analysis, and platform participation
 *
 * Reward Categories:
 * 1. Quality Publishing - CRED for high-credibility articles
 * 2. Accurate Verification - CRED for correct analysis/verification
 * 3. Staking Duration - CRED for long-term NEWS staking
 * 4. Community Contribution - CRED for DAO participation
 */
contract CREDRewardDistributor is Ownable {
    CRED public immutable credToken;
    NEWS public immutable newsToken;
    NewsStaking public immutable staking;
    ReporterRegistry public immutable reporterRegistry;

    // Reward rates (CRED per unit per day, scaled to 1e18)
    uint256 public publishRewardRate = 100 * 1e18; // 100 CRED per high-quality article
    uint256 public verificationRewardRate = 50 * 1e18; // 50 CRED per accurate verification
    uint256 public stakingRewardRate = 1 * 1e15; // 0.001 CRED per NEWS per day
    uint256 public governanceRewardRate = 25 * 1e18; // 25 CRED per DAO vote

    // Minimum credibility threshold for publishing rewards
    uint256 public minCredibilityForReward = 75; // 75% credibility score

    // Cooldown periods to prevent gaming
    uint256 public publishRewardCooldown = 1 days;
    uint256 public verificationRewardCooldown = 6 hours;

    // Tracking
    struct UserRewards {
        uint256 totalEarned;
        uint256 lastPublishReward;
        uint256 lastVerificationReward;
        uint256 lastStakingReward;
        uint256 publishCount;
        uint256 verificationCount;
        uint256 governanceCount;
    }

    mapping(address => UserRewards) public userRewards;

    // Total rewards distributed
    uint256 public totalRewardsDistributed;

    // Enable/disable specific reward types
    bool public publishRewardsEnabled = true;
    bool public verificationRewardsEnabled = true;
    bool public stakingRewardsEnabled = true;
    bool public governanceRewardsEnabled = true;

    // Events
    event RewardDistributed(
        address indexed user,
        uint256 amount,
        string rewardType
    );
    event RewardRateUpdated(string rewardType, uint256 newRate);
    event RewardToggled(string rewardType, bool enabled);

    constructor(
        address _credToken,
        address _newsToken,
        address _staking,
        address _reporterRegistry,
        address initialOwner
    ) Ownable(initialOwner) {
        credToken = CRED(_credToken);
        newsToken = NEWS(_newsToken);
        staking = NewsStaking(_staking);
        reporterRegistry = ReporterRegistry(_reporterRegistry);
    }

    /**
     * @notice Reward user for publishing high-quality news
     * @param reporter Address of the reporter
     * @param credibilityScore Credibility score of the article (0-100)
     */
    function rewardPublishing(
        address reporter,
        uint256 credibilityScore
    ) external onlyOwner {
        require(publishRewardsEnabled, "Publishing rewards disabled");
        require(
            credibilityScore >= minCredibilityForReward,
            "Credibility too low"
        );
        require(
            block.timestamp >=
                userRewards[reporter].lastPublishReward + publishRewardCooldown,
            "Cooldown period active"
        );

        // Calculate reward based on credibility
        // Higher credibility = more CRED
        uint256 rewardAmount = (publishRewardRate * credibilityScore) / 100;

        // Bonus for exceptional quality (90%+)
        if (credibilityScore >= 90) {
            rewardAmount = (rewardAmount * 150) / 100; // 1.5x bonus
        }

        // Mint and distribute CRED
        credToken.mint(reporter, rewardAmount);

        // Update tracking
        userRewards[reporter].totalEarned += rewardAmount;
        userRewards[reporter].lastPublishReward = block.timestamp;
        userRewards[reporter].publishCount++;
        totalRewardsDistributed += rewardAmount;

        emit RewardDistributed(reporter, rewardAmount, "Publishing");
    }

    /**
     * @notice Reward user for accurate verification/analysis
     * @param verifier Address of the verifier
     * @param wasAccurate Whether the verification was accurate
     */
    function rewardVerification(
        address verifier,
        bool wasAccurate
    ) external onlyOwner {
        require(verificationRewardsEnabled, "Verification rewards disabled");
        require(wasAccurate, "Verification must be accurate for reward");
        require(
            block.timestamp >=
                userRewards[verifier].lastVerificationReward +
                    verificationRewardCooldown,
            "Cooldown period active"
        );

        uint256 rewardAmount = verificationRewardRate;

        // Bonus for consistently accurate verifiers
        if (userRewards[verifier].verificationCount >= 10) {
            rewardAmount = (rewardAmount * 120) / 100; // 1.2x bonus
        }

        // Mint and distribute CRED
        credToken.mint(verifier, rewardAmount);

        // Update tracking
        userRewards[verifier].totalEarned += rewardAmount;
        userRewards[verifier].lastVerificationReward = block.timestamp;
        userRewards[verifier].verificationCount++;
        totalRewardsDistributed += rewardAmount;

        emit RewardDistributed(verifier, rewardAmount, "Verification");
    }

    /**
     * @notice Claim staking rewards based on staked NEWS tokens
     * @dev Users can claim once per day based on their stake
     */
    function claimStakingRewards() external {
        require(stakingRewardsEnabled, "Staking rewards disabled");

        (uint256 stakedAmount, uint256 stakedAt) = staking.stakes(msg.sender);
        require(stakedAmount > 0, "No stake found");
        require(stakedAt > 0, "Invalid stake");

        // Calculate time since last reward
        uint256 lastReward = userRewards[msg.sender].lastStakingReward;
        if (lastReward == 0) {
            lastReward = stakedAt;
        }

        require(
            block.timestamp >= lastReward + 1 days,
            "Already claimed today"
        );

        // Calculate days since last claim
        uint256 daysElapsed = (block.timestamp - lastReward) / 1 days;

        // Calculate reward: stakedAmount * rate * days
        uint256 rewardAmount = (stakedAmount *
            stakingRewardRate *
            daysElapsed) / 1e18;

        // Cap maximum claim to prevent exploitation
        uint256 maxClaim = stakedAmount / 10; // Max 10% of stake per claim
        if (rewardAmount > maxClaim) {
            rewardAmount = maxClaim;
        }

        // Mint and distribute CRED
        credToken.mint(msg.sender, rewardAmount);

        // Update tracking
        userRewards[msg.sender].totalEarned += rewardAmount;
        userRewards[msg.sender].lastStakingReward = block.timestamp;
        totalRewardsDistributed += rewardAmount;

        emit RewardDistributed(msg.sender, rewardAmount, "Staking");
    }

    /**
     * @notice Reward user for DAO governance participation
     * @param voter Address of the voter
     */
    function rewardGovernanceParticipation(address voter) external onlyOwner {
        require(governanceRewardsEnabled, "Governance rewards disabled");

        uint256 rewardAmount = governanceRewardRate;

        // Bonus for active participants (10+ votes)
        if (userRewards[voter].governanceCount >= 10) {
            rewardAmount = (rewardAmount * 115) / 100; // 1.15x bonus
        }

        // Mint and distribute CRED
        credToken.mint(voter, rewardAmount);

        // Update tracking
        userRewards[voter].totalEarned += rewardAmount;
        userRewards[voter].governanceCount++;
        totalRewardsDistributed += rewardAmount;

        emit RewardDistributed(voter, rewardAmount, "Governance");
    }

    /**
     * @notice Batch reward multiple contributors (gas efficient)
     * @param contributors Array of contributor addresses
     * @param amounts Array of reward amounts
     * @param rewardTypes Array of reward type strings
     */
    function batchReward(
        address[] calldata contributors,
        uint256[] calldata amounts,
        string[] calldata rewardTypes
    ) external onlyOwner {
        require(
            contributors.length == amounts.length &&
                amounts.length == rewardTypes.length,
            "Array length mismatch"
        );

        for (uint i = 0; i < contributors.length; i++) {
            credToken.mint(contributors[i], amounts[i]);
            userRewards[contributors[i]].totalEarned += amounts[i];
            totalRewardsDistributed += amounts[i];

            emit RewardDistributed(contributors[i], amounts[i], rewardTypes[i]);
        }
    }

    /**
     * @notice Get user's reward statistics
     * @param user Address to query
     */
    function getUserRewardStats(
        address user
    )
        external
        view
        returns (
            uint256 totalEarned,
            uint256 publishCount,
            uint256 verificationCount,
            uint256 governanceCount,
            uint256 currentCREDBalance
        )
    {
        UserRewards memory rewards = userRewards[user];
        return (
            rewards.totalEarned,
            rewards.publishCount,
            rewards.verificationCount,
            rewards.governanceCount,
            credToken.balanceOf(user)
        );
    }

    /**
     * @notice Update publishing reward rate
     * @param newRate New rate in CRED tokens (scaled to 1e18)
     */
    function updatePublishRewardRate(uint256 newRate) external onlyOwner {
        publishRewardRate = newRate;
        emit RewardRateUpdated("Publishing", newRate);
    }

    /**
     * @notice Update verification reward rate
     * @param newRate New rate in CRED tokens (scaled to 1e18)
     */
    function updateVerificationRewardRate(uint256 newRate) external onlyOwner {
        verificationRewardRate = newRate;
        emit RewardRateUpdated("Verification", newRate);
    }

    /**
     * @notice Update staking reward rate
     * @param newRate New rate in CRED tokens (scaled to 1e18)
     */
    function updateStakingRewardRate(uint256 newRate) external onlyOwner {
        stakingRewardRate = newRate;
        emit RewardRateUpdated("Staking", newRate);
    }

    /**
     * @notice Update governance reward rate
     * @param newRate New rate in CRED tokens (scaled to 1e18)
     */
    function updateGovernanceRewardRate(uint256 newRate) external onlyOwner {
        governanceRewardRate = newRate;
        emit RewardRateUpdated("Governance", newRate);
    }

    /**
     * @notice Toggle publishing rewards
     */
    function togglePublishRewards(bool enabled) external onlyOwner {
        publishRewardsEnabled = enabled;
        emit RewardToggled("Publishing", enabled);
    }

    /**
     * @notice Toggle verification rewards
     */
    function toggleVerificationRewards(bool enabled) external onlyOwner {
        verificationRewardsEnabled = enabled;
        emit RewardToggled("Verification", enabled);
    }

    /**
     * @notice Toggle staking rewards
     */
    function toggleStakingRewards(bool enabled) external onlyOwner {
        stakingRewardsEnabled = enabled;
        emit RewardToggled("Staking", enabled);
    }

    /**
     * @notice Toggle governance rewards
     */
    function toggleGovernanceRewards(bool enabled) external onlyOwner {
        governanceRewardsEnabled = enabled;
        emit RewardToggled("Governance", enabled);
    }

    /**
     * @notice Update minimum credibility threshold
     * @param newThreshold New threshold (0-100)
     */
    function updateMinCredibility(uint256 newThreshold) external onlyOwner {
        require(newThreshold <= 100, "Invalid threshold");
        minCredibilityForReward = newThreshold;
    }
}
