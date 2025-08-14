// src/governance/interfaces/IDelegation.sol
pragma solidity ^0.8.24;

interface IDelegation {
    function setDelegate(uint256 topic, address delegate) external;

    function getDelegate(
        address user,
        uint256 topic
    ) external view returns (address);
}
