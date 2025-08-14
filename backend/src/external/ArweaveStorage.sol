// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ArweaveStorage {
    mapping(string => address) public contentOwner;

    event ContentStored(string indexed contentHash, address indexed owner);

    function storeReference(string memory contentHash, address owner) external {
        contentOwner[contentHash] = owner;
        emit ContentStored(contentHash, owner);
    }
}
