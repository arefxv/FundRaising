// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// Importing Chainlink's AggregatorV3Interface to interact with the price feed contract
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Library for converting ETH values to USD using Chainlink price feeds
library PriceConverter {
    /**
     * @dev Fetches the latest ETH/USD price from the Chainlink price feed.
     * @param priceFeed The address of the Chainlink AggregatorV3Interface contract.
     * @return The latest ETH price in USD scaled to 18 decimals.
     */
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 answer,,,) = priceFeed.latestRoundData(); // Get the latest price data from the feed
        return uint256(answer * 1e10); // Scale the price to 18 decimals
    }

    /**
     * @dev Converts a specified amount of ETH to its equivalent USD value.
     * @param ethAmount The amount of ETH to convert (in wei).
     * @param priceFeed The address of the Chainlink AggregatorV3Interface contract.
     * @return The USD equivalent of the specified ETH amount, scaled to 18 decimals.
     */
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed); // Get the current ETH price in USD
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; // Convert ETH to USD
        return ethAmountInUsd; // Return the converted value
    }
}
