// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../staking/NewsStaking.sol";
import "../../tokens/CRED.sol";

/**
 * @title ReputationWeightedVoting
 * @notice Implements hybrid voting that balances economic stake (NEWS) and reputation (CRED)
 * @dev Prevents plutocratic capture by giving weight to both wealth and merit
 *
 * From whitepaper:
 * "Voting power will be a function of both staked NEWS (economic stake) and earned CRED
 * (reputational stake). This gives more weight to trusted, long-term contributors and less
 * to financially motivated 'whales' who could otherwise dominate governance."
 */
library ReputationWeightedVoting {
    // Weight distribution (in basis points, total = 10000)
    uint256 constant ECONOMIC_WEIGHT = 5000; // 50% from NEWS tokens
    uint256 constant REPUTATION_WEIGHT = 5000; // 50% from CRED tokens

    /**
     * @notice Calculate hybrid voting power combining economic and reputational stake
     * @param staking NewsStaking contract
     * @param credToken CRED token contract
     * @param voter Address of the voter
     * @return votingPower Total voting power (scaled to 1e18)
     *
     * Formula: VP = (NEWS_staked * ECONOMIC_WEIGHT) + (CRED_balance * REPUTATION_WEIGHT)
     */
    function calculateVotingPower(
        NewsStaking staking,
        CRED credToken,
        address voter
    ) internal view returns (uint256 votingPower) {
        // Get economic stake (NEWS tokens)
        (uint256 newsStake, ) = staking.stakes(voter);

        // Get reputation stake (CRED tokens)
        uint256 credBalance = credToken.balanceOf(voter);

        // Calculate weighted voting power
        uint256 economicPower = (newsStake * ECONOMIC_WEIGHT) / 10000;
        uint256 reputationPower = (credBalance * REPUTATION_WEIGHT) / 10000;

        votingPower = economicPower + reputationPower;

        return votingPower;
    }

    /**
     * @notice Calculate voting power with custom weights
     * @param staking NewsStaking contract
     * @param credToken CRED token contract
     * @param voter Address of the voter
     * @param economicWeight Weight for NEWS tokens (in basis points)
     * @param reputationWeight Weight for CRED tokens (in basis points)
     * @return votingPower Total voting power
     */
    function calculateCustomWeightedPower(
        NewsStaking staking,
        CRED credToken,
        address voter,
        uint256 economicWeight,
        uint256 reputationWeight
    ) internal view returns (uint256 votingPower) {
        require(
            economicWeight + reputationWeight == 10000,
            "Weights must sum to 10000"
        );

        (uint256 newsStake, ) = staking.stakes(voter);
        uint256 credBalance = credToken.balanceOf(voter);

        uint256 economicPower = (newsStake * economicWeight) / 10000;
        uint256 reputationPower = (credBalance * reputationWeight) / 10000;

        votingPower = economicPower + reputationPower;

        return votingPower;
    }

    /**
     * @notice Calculate total voting power in the system
     * @param staking NewsStaking contract
     * @param credToken CRED token contract
     * @return totalPower Total voting power of all stakers
     */
    function calculateTotalVotingPower(
        NewsStaking staking,
        CRED credToken
    ) internal view returns (uint256 totalPower) {
        address[] memory stakers = staking.getAllStakers();

        for (uint i = 0; i < stakers.length; i++) {
            totalPower += calculateVotingPower(staking, credToken, stakers[i]);
        }

        return totalPower;
    }

    /**
     * @notice Check if voter meets minimum voting power threshold
     * @param staking NewsStaking contract
     * @param credToken CRED token contract
     * @param voter Address to check
     * @param minimumPower Minimum required voting power
     * @return bool Whether voter meets threshold
     */
    function meetsVotingThreshold(
        NewsStaking staking,
        CRED credToken,
        address voter,
        uint256 minimumPower
    ) internal view returns (bool) {
        uint256 voterPower = calculateVotingPower(staking, credToken, voter);
        return voterPower >= minimumPower;
    }

    /**
     * @notice Calculate vote weight for a specific number of votes
     * @param votingPower Total voting power of the voter
     * @param votes Number of votes to cast
     * @return weight Actual weight of the votes
     *
     * This allows implementing different vote weighting schemes:
     * - Linear: weight = votes
     * - Square root: weight = sqrt(votes)
     * - Quadratic cost: cost = votes^2, weight = votes
     */
    function calculateVoteWeight(
        uint256 votingPower,
        uint256 votes
    ) internal pure returns (uint256 weight) {
        require(votes <= votingPower, "Insufficient voting power");

        // Linear weight for now
        // Can be modified to implement other schemes
        weight = votes;

        return weight;
    }

    /**
     * @notice Get voting power breakdown for transparency
     * @param staking NewsStaking contract
     * @param credToken CRED token contract
     * @param voter Address to query
     * @return newsStake Amount of NEWS staked
     * @return credBalance Amount of CRED held
     * @return economicPower Voting power from NEWS
     * @return reputationPower Voting power from CRED
     * @return totalPower Total voting power
     */
    function getVotingPowerBreakdown(
        NewsStaking staking,
        CRED credToken,
        address voter
    )
        internal
        view
        returns (
            uint256 newsStake,
            uint256 credBalance,
            uint256 economicPower,
            uint256 reputationPower,
            uint256 totalPower
        )
    {
        (newsStake, ) = staking.stakes(voter);
        credBalance = credToken.balanceOf(voter);

        economicPower = (newsStake * ECONOMIC_WEIGHT) / 10000;
        reputationPower = (credBalance * REPUTATION_WEIGHT) / 10000;
        totalPower = economicPower + reputationPower;

        return (
            newsStake,
            credBalance,
            economicPower,
            reputationPower,
            totalPower
        );
    }
}
