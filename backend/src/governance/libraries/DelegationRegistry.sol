// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IDelegation.sol";

contract DelegationRegistry is IDelegation {
    mapping(address => mapping(uint256 => address)) private _delegates;

    event DelegateSet(
        address indexed delegator,
        uint256 indexed topic,
        address indexed delegate
    );

    function setDelegate(uint256 topic, address delegate) external override {
        _delegates[msg.sender][topic] = delegate;
        emit DelegateSet(msg.sender, topic, delegate);
    }

    function getDelegate(
        address delegator,
        uint256 topic
    ) external view override returns (address) {
        address delegate = _delegates[delegator][topic];
        return delegate == address(0) ? delegator : delegate;
    }
}
