// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library SANUB {
    function calculateBelief(
        uint256[] memory scores
    ) internal pure returns (uint256) {
        uint256 sum = 0;
        for (uint i = 0; i < scores.length; i++) {
            sum += scores[i];
        }
        return sum / scores.length;
    }

    function calculateImportance(
        uint256 verifiersCount,
        uint256 totalUsers
    ) internal pure returns (uint256) {
        return (verifiersCount * 1e18) / totalUsers; // Fixed-point arithmetic
    }

    function sigmoidFunction(uint256 belief) internal pure returns (uint256) {
        // Sigmoid implementation (simplified)
        return 1e18 / (1e18 + exp(-(int256(belief) - 0.75e18)));
    }

    // Helper exponential function (simplified)
    function exp(int256 x) private pure returns (uint256) {
        // Simplified implementation for demonstration
        return uint256(1e18 + x + (x * x) / (2 * 1e18));
    }
}
