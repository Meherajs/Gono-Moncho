// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../tokens/NEWS.sol";

/**
 * @title OrganizationStaking
 * @notice Enables news organizations to stake on behalf of their affiliated journalists
 * @dev Per whitepaper Section VI: Delegated Stakes
 *
 * Organizations can:
 * - Stake NEWS tokens to support their journalists
 * - Distribute staking rewards among journalists
 * - Amplify journalist credibility through organizational backing
 */
contract OrganizationStaking is Ownable {
    NEWS public newsToken;

    // Minimum stake per journalist
    uint256 public constant MIN_STAKE_PER_JOURNALIST = 100 * 1e18; // 100 NEWS

    struct OrganizationStake {
        uint256 totalStaked;
        uint256 activeJournalists;
        uint256 rewardsEarned;
        uint256 rewardsClaimed;
        uint256 lastUpdateTime;
        bool active;
    }

    struct JournalistAllocation {
        uint256 stakedAmount;
        uint256 rewardsEarned;
        uint256 rewardsClaimed;
        uint256 allocationDate;
        bool active;
    }

    // Organization => stake data
    mapping(address => OrganizationStake) public organizationStakes;

    // Organization => journalist => allocation
    mapping(address => mapping(address => JournalistAllocation))
        public allocations;

    // Organization => journalist list
    mapping(address => address[]) public organizationJournalists;

    // Journalist => organization list (journalists can be backed by multiple orgs)
    mapping(address => address[]) public journalistOrganizations;

    // Staking reward rate: 10% APY
    uint256 public constant ANNUAL_REWARD_RATE = 1000; // 10.00% (2 decimal precision)
    uint256 public constant RATE_DENOMINATOR = 10000;
    uint256 public constant SECONDS_PER_YEAR = 365 days;

    // Track total staked across all organizations
    uint256 public totalOrganizationStake;

    // Events
    event OrganizationStakeDeposited(
        address indexed organization,
        uint256 amount,
        uint256 totalStaked
    );

    event StakeAllocatedToJournalist(
        address indexed organization,
        address indexed journalist,
        uint256 amount
    );

    event StakeDeallocated(
        address indexed organization,
        address indexed journalist,
        uint256 amount
    );

    event RewardsDistributed(
        address indexed organization,
        uint256 totalRewards,
        uint256 journalistCount
    );

    event JournalistRewardsClaimed(
        address indexed journalist,
        address indexed organization,
        uint256 amount
    );

    event OrganizationStakeWithdrawn(
        address indexed organization,
        uint256 amount
    );

    constructor(
        address _newsToken,
        address initialOwner
    ) Ownable(initialOwner) {
        newsToken = NEWS(_newsToken);
    }

    /**
     * @notice Deposit stake for organization
     * @param amount Amount of NEWS tokens to stake
     */
    function depositOrganizationStake(uint256 amount) external {
        require(amount > 0, "Amount must be positive");

        // Transfer tokens from organization to contract
        require(
            newsToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        // Update organization stake
        OrganizationStake storage stake = organizationStakes[msg.sender];

        // Calculate pending rewards before updating
        if (stake.active && stake.totalStaked > 0) {
            _updateRewards(msg.sender);
        }

        stake.totalStaked += amount;
        stake.active = true;
        stake.lastUpdateTime = block.timestamp;

        totalOrganizationStake += amount;

        emit OrganizationStakeDeposited(msg.sender, amount, stake.totalStaked);
    }

    /**
     * @notice Allocate stake to a journalist
     * @param journalist Address of journalist to back
     * @param amount Amount to allocate
     */
    function allocateToJournalist(address journalist, uint256 amount) external {
        require(journalist != address(0), "Invalid journalist");
        require(amount >= MIN_STAKE_PER_JOURNALIST, "Insufficient allocation");

        OrganizationStake storage orgStake = organizationStakes[msg.sender];
        require(orgStake.active, "Organization not staking");

        // Calculate available stake
        uint256 allocatedStake = _getTotalAllocated(msg.sender);
        uint256 availableStake = orgStake.totalStaked - allocatedStake;

        require(availableStake >= amount, "Insufficient unallocated stake");

        JournalistAllocation storage allocation = allocations[msg.sender][
            journalist
        ];

        if (!allocation.active) {
            // New allocation
            allocation.stakedAmount = amount;
            allocation.allocationDate = block.timestamp;
            allocation.active = true;

            organizationJournalists[msg.sender].push(journalist);
            journalistOrganizations[journalist].push(msg.sender);

            orgStake.activeJournalists++;
        } else {
            // Increase existing allocation
            allocation.stakedAmount += amount;
        }

        emit StakeAllocatedToJournalist(msg.sender, journalist, amount);
    }

    /**
     * @notice Deallocate stake from journalist
     * @param journalist Journalist to remove stake from
     * @param amount Amount to deallocate
     */
    function deallocateFromJournalist(
        address journalist,
        uint256 amount
    ) external {
        JournalistAllocation storage allocation = allocations[msg.sender][
            journalist
        ];
        require(allocation.active, "No allocation found");
        require(
            allocation.stakedAmount >= amount,
            "Insufficient allocated amount"
        );

        // Update rewards before deallocation
        _updateJournalistRewards(msg.sender, journalist);

        allocation.stakedAmount -= amount;

        // If fully deallocated, mark as inactive
        if (allocation.stakedAmount == 0) {
            allocation.active = false;
            organizationStakes[msg.sender].activeJournalists--;
        }

        emit StakeDeallocated(msg.sender, journalist, amount);
    }

    /**
     * @notice Calculate and distribute rewards to all journalists
     */
    function distributeRewards() external {
        OrganizationStake storage orgStake = organizationStakes[msg.sender];
        require(orgStake.active, "Organization not staking");

        _updateRewards(msg.sender);

        // Distribute proportionally to allocated journalists
        address[] memory journalists = organizationJournalists[msg.sender];
        uint256 totalRewardsToDistribute = orgStake.rewardsEarned -
            orgStake.rewardsClaimed;

        if (totalRewardsToDistribute > 0) {
            for (uint256 i = 0; i < journalists.length; i++) {
                address journalist = journalists[i];
                JournalistAllocation storage allocation = allocations[
                    msg.sender
                ][journalist];

                if (allocation.active && allocation.stakedAmount > 0) {
                    // Calculate journalist's share based on their allocation
                    uint256 journalistShare = (totalRewardsToDistribute *
                        allocation.stakedAmount) / orgStake.totalStaked;
                    allocation.rewardsEarned += journalistShare;
                }
            }
        }

        emit RewardsDistributed(
            msg.sender,
            totalRewardsToDistribute,
            journalists.length
        );
    }

    /**
     * @notice Journalist claims their rewards from organization
     * @param organization Organization to claim from
     */
    function claimJournalistRewards(address organization) external {
        JournalistAllocation storage allocation = allocations[organization][
            msg.sender
        ];
        require(allocation.active, "No active allocation");

        _updateJournalistRewards(organization, msg.sender);

        uint256 claimable = allocation.rewardsEarned -
            allocation.rewardsClaimed;
        require(claimable > 0, "No rewards to claim");

        allocation.rewardsClaimed += claimable;
        organizationStakes[organization].rewardsClaimed += claimable;

        // Transfer rewards to journalist
        require(newsToken.transfer(msg.sender, claimable), "Transfer failed");

        emit JournalistRewardsClaimed(msg.sender, organization, claimable);
    }

    /**
     * @notice Withdraw unallocated organization stake
     * @param amount Amount to withdraw
     */
    function withdrawOrganizationStake(uint256 amount) external {
        OrganizationStake storage orgStake = organizationStakes[msg.sender];
        require(orgStake.active, "No active stake");

        uint256 allocatedStake = _getTotalAllocated(msg.sender);
        uint256 availableToWithdraw = orgStake.totalStaked - allocatedStake;

        require(
            availableToWithdraw >= amount,
            "Insufficient unallocated stake"
        );

        orgStake.totalStaked -= amount;
        totalOrganizationStake -= amount;

        // Transfer tokens back to organization
        require(newsToken.transfer(msg.sender, amount), "Transfer failed");

        emit OrganizationStakeWithdrawn(msg.sender, amount);
    }

    /**
     * @notice Get journalist's stake backing from organization
     */
    function getJournalistStake(
        address organization,
        address journalist
    ) external view returns (uint256) {
        return allocations[organization][journalist].stakedAmount;
    }

    /**
     * @notice Get total stake backing a journalist across all organizations
     */
    function getTotalJournalistBacking(
        address journalist
    ) external view returns (uint256 total) {
        address[] memory orgs = journalistOrganizations[journalist];
        for (uint256 i = 0; i < orgs.length; i++) {
            if (allocations[orgs[i]][journalist].active) {
                total += allocations[orgs[i]][journalist].stakedAmount;
            }
        }
    }

    /**
     * @notice Get organization's journalists
     */
    function getOrganizationJournalists(
        address organization
    ) external view returns (address[] memory) {
        return organizationJournalists[organization];
    }

    /**
     * @notice Get claimable rewards for journalist from organization
     */
    function getClaimableRewards(
        address organization,
        address journalist
    ) external view returns (uint256) {
        JournalistAllocation storage allocation = allocations[organization][
            journalist
        ];
        if (!allocation.active) return 0;

        // Calculate pending rewards
        uint256 pending = _calculatePendingRewards(
            allocation.stakedAmount,
            allocation.allocationDate
        );

        return allocation.rewardsEarned + pending - allocation.rewardsClaimed;
    }

    /**
     * @notice Internal: Update organization rewards
     */
    function _updateRewards(address organization) internal {
        OrganizationStake storage stake = organizationStakes[organization];

        if (stake.totalStaked > 0 && stake.lastUpdateTime > 0) {
            uint256 timeElapsed = block.timestamp - stake.lastUpdateTime;
            uint256 rewards = (stake.totalStaked *
                ANNUAL_REWARD_RATE *
                timeElapsed) / (RATE_DENOMINATOR * SECONDS_PER_YEAR);

            stake.rewardsEarned += rewards;
            stake.lastUpdateTime = block.timestamp;
        }
    }

    /**
     * @notice Internal: Update journalist-specific rewards
     */
    function _updateJournalistRewards(
        address organization,
        address journalist
    ) internal {
        JournalistAllocation storage allocation = allocations[organization][
            journalist
        ];

        if (allocation.active && allocation.stakedAmount > 0) {
            uint256 pending = _calculatePendingRewards(
                allocation.stakedAmount,
                allocation.allocationDate
            );
            allocation.rewardsEarned += pending;
            allocation.allocationDate = block.timestamp;
        }
    }

    /**
     * @notice Internal: Calculate pending rewards
     */
    function _calculatePendingRewards(
        uint256 amount,
        uint256 since
    ) internal view returns (uint256) {
        if (amount == 0 || since == 0) return 0;

        uint256 timeElapsed = block.timestamp - since;
        return
            (amount * ANNUAL_REWARD_RATE * timeElapsed) /
            (RATE_DENOMINATOR * SECONDS_PER_YEAR);
    }

    /**
     * @notice Internal: Get total allocated stake for organization
     */
    function _getTotalAllocated(
        address organization
    ) internal view returns (uint256 total) {
        address[] memory journalists = organizationJournalists[organization];
        for (uint256 i = 0; i < journalists.length; i++) {
            JournalistAllocation storage allocation = allocations[organization][
                journalists[i]
            ];
            if (allocation.active) {
                total += allocation.stakedAmount;
            }
        }
    }
}
