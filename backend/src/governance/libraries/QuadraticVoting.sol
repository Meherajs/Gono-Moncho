// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../staking/NewsStaking.sol";

library QuadraticVoting {
    function calculateCost(uint256 votes) internal pure returns (uint256) {
        return votes * votes;
    }

    function validateVote(
        NewsStaking staking,
        address voter,
        uint256 votes
    ) internal view {
        uint256 cost = calculateCost(votes);
        (uint256 amount, ) = staking.stakes(voter);
        require(amount >= cost, "Insufficient stake");
    }
}
