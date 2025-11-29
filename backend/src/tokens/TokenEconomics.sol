// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./NEWS.sol";

/**
 * @title TokenEconomics
 * @notice Implements the value-capture tokenomics model with buy-back-and-burn mechanism
 * @dev Collects platform fees and uses them to buy back and burn NEWS tokens
 */
contract TokenEconomics is Ownable {
    NEWS public immutable newsToken;

    // Revenue sources
    uint256 public totalRevenue;
    uint256 public totalBurned;

    // Fee structure (in basis points, 1% = 100)
    uint256 public contentSyndicationFee = 500; // 5%
    uint256 public premiumAnalyticsFee = 1000; // 10%
    uint256 public subscriptionFee = 300; // 3%

    // Buyback configuration
    uint256 public buybackPercentage = 5000; // 50% of revenue goes to buyback
    uint256 public burnPercentage = 10000; // 100% of bought back tokens are burned

    // Treasury for DAO operations
    address public treasuryAddress;

    // Events
    event RevenueCollected(
        address indexed source,
        uint256 amount,
        string revenueType
    );
    event TokensBoughtBack(uint256 amount, uint256 tokensPurchased);
    event TokensBurned(uint256 amount);
    event FeeUpdated(string feeType, uint256 newFee);
    event TreasuryUpdated(address indexed newTreasury);

    constructor(
        address _newsToken,
        address _treasury,
        address initialOwner
    ) Ownable(initialOwner) {
        newsToken = NEWS(_newsToken);
        treasuryAddress = _treasury;
    }

    /**
     * @notice Collect revenue from content syndication
     * @param amount Amount of revenue collected
     */
    function collectSyndicationRevenue(uint256 amount) external payable {
        require(msg.value == amount, "Incorrect payment");
        totalRevenue += amount;
        emit RevenueCollected(msg.sender, amount, "Syndication");

        _processBuybackAndBurn();
    }

    /**
     * @notice Collect revenue from premium analytics subscriptions
     * @param amount Amount of revenue collected
     */
    function collectAnalyticsRevenue(uint256 amount) external payable {
        require(msg.value == amount, "Incorrect payment");
        totalRevenue += amount;
        emit RevenueCollected(msg.sender, amount, "Analytics");

        _processBuybackAndBurn();
    }

    /**
     * @notice Collect revenue from subscription-based publishing
     * @param amount Amount of revenue collected
     */
    function collectSubscriptionRevenue(uint256 amount) external payable {
        require(msg.value == amount, "Incorrect payment");
        totalRevenue += amount;
        emit RevenueCollected(msg.sender, amount, "Subscription");

        _processBuybackAndBurn();
    }

    /**
     * @notice Internal function to buy back and burn NEWS tokens
     * @dev Uses a portion of accumulated revenue to create deflationary pressure
     */
    function _processBuybackAndBurn() internal {
        uint256 buybackAmount = (address(this).balance * buybackPercentage) /
            10000;

        if (buybackAmount > 0) {
            // In production, this would interact with a DEX to buy tokens
            // For now, we'll simulate by directly burning tokens if the contract holds any
            uint256 tokenBalance = newsToken.balanceOf(address(this));

            if (tokenBalance > 0) {
                uint256 burnAmount = (tokenBalance * burnPercentage) / 10000;
                newsToken.burnFrom(address(this), burnAmount);
                totalBurned += burnAmount;

                emit TokensBurned(burnAmount);
            }

            emit TokensBoughtBack(buybackAmount, tokenBalance);
        }

        // Transfer remaining to treasury
        uint256 treasuryAmount = address(this).balance;
        if (treasuryAmount > 0 && treasuryAddress != address(0)) {
            (bool success, ) = treasuryAddress.call{value: treasuryAmount}("");
            require(success, "Treasury transfer failed");
        }
    }

    /**
     * @notice Manual buyback execution (DAO controlled)
     */
    function executeBuyback() external onlyOwner {
        _processBuybackAndBurn();
    }

    /**
     * @notice Update content syndication fee
     * @param newFee New fee in basis points
     */
    function updateSyndicationFee(uint256 newFee) external onlyOwner {
        require(newFee <= 1000, "Fee too high"); // Max 10%
        contentSyndicationFee = newFee;
        emit FeeUpdated("Syndication", newFee);
    }

    /**
     * @notice Update premium analytics fee
     * @param newFee New fee in basis points
     */
    function updateAnalyticsFee(uint256 newFee) external onlyOwner {
        require(newFee <= 2000, "Fee too high"); // Max 20%
        premiumAnalyticsFee = newFee;
        emit FeeUpdated("Analytics", newFee);
    }

    /**
     * @notice Update subscription fee
     * @param newFee New fee in basis points
     */
    function updateSubscriptionFee(uint256 newFee) external onlyOwner {
        require(newFee <= 1000, "Fee too high"); // Max 10%
        subscriptionFee = newFee;
        emit FeeUpdated("Subscription", newFee);
    }

    /**
     * @notice Update treasury address
     * @param newTreasury New treasury address
     */
    function updateTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), "Invalid address");
        treasuryAddress = newTreasury;
        emit TreasuryUpdated(newTreasury);
    }

    /**
     * @notice Get contract statistics
     */
    function getStats()
        external
        view
        returns (uint256 revenue, uint256 burned, uint256 balance)
    {
        return (totalRevenue, totalBurned, address(this).balance);
    }

    // Allow contract to receive ETH
    receive() external payable {
        totalRevenue += msg.value;
        emit RevenueCollected(msg.sender, msg.value, "Direct");
    }
}
