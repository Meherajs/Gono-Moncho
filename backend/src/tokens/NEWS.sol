// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";

contract NEWS is ERC20, ERC20Permit, ERC20Burnable, Ownable, ERC20Votes {
    uint256 private constant INITIAL_SUPPLY = 100_000_000 * 1e18;

    constructor(
        address initialOwner
    )
        ERC20("Gono Moncho News", "NEWS")
        Ownable(initialOwner)
        ERC20Permit("Gono Moncho News")
    {
        _mint(initialOwner, INITIAL_SUPPLY);
    }

    // Overrides required for ERC20Votes
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._update(from, to, amount);
    }

    function nonces(
        address owner
    ) public view virtual override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    // DAO-controlled minting
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Governance-controlled token burns
    function burnFrom(
        address account,
        uint256 amount
    ) public override onlyOwner {
        _burn(account, amount);
    }
}
