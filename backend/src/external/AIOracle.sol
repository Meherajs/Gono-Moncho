// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface AIOracle {
    function requestAnalysis(string memory contentHash) external;

    function getAnalysis(
        string memory contentHash
    ) external view returns (uint256 credibilityScore);
}
