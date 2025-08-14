// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../tokens/NEWS.sol";
import "../tokens/CRED.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NewsStaking is Ownable {
    NEWS public immutable newsToken;
    CRED public immutable credToken;
    address public governance;

    struct Stake {
        uint256 amount;
        uint256 stakedAt;
    }

    mapping(address => Stake) public stakes;

    event Staked(address indexed user, uint256 amount);
    event Slashed(address indexed user, uint256 amount);

    constructor(
        address _newsToken,
        address _credToken,
        address initialOwner
    ) Ownable(initialOwner) {
        newsToken = NEWS(_newsToken);
        credToken = CRED(_credToken);
        governance = msg.sender; // Temporary, will be set by DAO
    }

    function setGovernance(address _governance) external onlyOwner {
        governance = _governance;
    }

    function stake(uint256 amount) external {
        newsToken.transferFrom(msg.sender, address(this), amount);
        stakes[msg.sender] = Stake({
            amount: stakes[msg.sender].amount + amount,
            stakedAt: block.timestamp
        });
        emit Staked(msg.sender, amount);
    }

    function slash(address user, uint256 amount) external {
        require(msg.sender == governance, "Unauthorized");
        require(stakes[user].amount >= amount, "Insufficient stake");

        stakes[user].amount -= amount;
        newsToken.burn(amount);
        emit Slashed(user, amount);
    }

    function calculateVoteCost(uint256 votes) public pure returns (uint256) {
        return votes * votes;
    }
}
