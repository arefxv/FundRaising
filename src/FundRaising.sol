//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {console} from "lib/forge-std/src/console.sol";

/**
 * @title FundRaising
 * 
 * @dev This contract enables a decentralized fundraising system where contributors 
 *      can fund in either ETH or USD (using a price feed for conversion). The owner 
 *      can withdraw funds once fundraising goals are achieved.
 * 
 * Features:
 * - Allows funding with ETH and USD.
 * - Implements funding limits per contributor (min and max).
 * - Tracks contributions in ETH and USD separately.
 * - Supports multiple funders and prevents exceeding maximum contributors.
 * - Uses Chainlink Price Feed for ETH/USD conversion.
 * - Enforces fundraising goals and funding closure upon completion.
 * - Provides withdraw functionality only for the contract owner.
 * 
 * @author ArefXV
 */


contract FundRaising {
    using PriceConverter for uint256;

    error FundRaising__sendMoreAmountToFund();
    error FundRaising__canNotFundMoreThanMaximumAmount();
    error FundRaising__fundingIsClosed();
    error FundRaising__youAreNotTheOwner();
    error FundRaising__fundingIsFull();

    uint256 private constant MINIMUM_ETH = 1e15;
    uint256 private constant MAXIMUM_ETH = 1e17;
    uint256 private constant GOAL_IN_ETH = 1e18;
    uint256 private constant MAXIMUM_FUNDERS = 20;
    uint256 private constant MINIMUM_USD = 10e18;
    uint256 private constant MAXIMUM_USD = 500e18;
    uint256 private constant GOAL_IN_USD = 2000e18;

    AggregatorV3Interface private s_priceFeed;
    uint256 private s_totalFundsInUsd;
    uint256 private s_totalFundsInEth;

    address private immutable i_owner;

    address[] private s_listOfFunders;
    mapping(address => uint256) private s_funderToAmountFundedWithEth;
    mapping(address => uint256) private s_funderToAmountFundedWithUsd;

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundRaising__youAreNotTheOwner();
        }
        _;
    }

    modifier maxFunders() {
        if (s_listOfFunders.length >= MAXIMUM_FUNDERS) {
            revert FundRaising__fundingIsFull();
        }
        _;
    }

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    function fundWithEth() public payable maxFunders {
        console.log("Total Funds In ETH Before:", s_totalFundsInEth);
        if (msg.value < MINIMUM_ETH) {
            revert FundRaising__sendMoreAmountToFund();
        }
        if (msg.value > MAXIMUM_ETH) {
            revert FundRaising__canNotFundMoreThanMaximumAmount();
        }
        console.log("ETH sent:", msg.value);
        if (s_totalFundsInEth + msg.value > GOAL_IN_ETH) {
            revert FundRaising__fundingIsClosed();
        }
        s_listOfFunders.push(msg.sender);
        s_funderToAmountFundedWithEth[msg.sender] += msg.value;
        s_totalFundsInEth += msg.value;
        console.log("Total Funds In ETH After:", s_totalFundsInEth);
    }

    function fundWithUsd() public payable maxFunders {
        console.log("Total Funds In USD Before:", s_totalFundsInUsd);

        uint256 convertedUsd = msg.value.getConversionRate(s_priceFeed);
        console.log("Converted USD:", convertedUsd);

        if (convertedUsd < MINIMUM_USD) {
            revert FundRaising__sendMoreAmountToFund();
        }
        if (convertedUsd > MAXIMUM_USD) {
            revert FundRaising__canNotFundMoreThanMaximumAmount();
        }

        console.log("USD sent:", convertedUsd);
        if (s_totalFundsInUsd + convertedUsd > GOAL_IN_USD) {
            revert FundRaising__fundingIsClosed();
        }
        s_listOfFunders.push(msg.sender);
        s_funderToAmountFundedWithUsd[msg.sender] += convertedUsd;
        s_totalFundsInUsd += convertedUsd;

        console.log("Total Funds In USD After:", s_totalFundsInUsd);
    }

    function withdraw() public onlyOwner {
        address[] memory funders = s_listOfFunders;
        uint256 contractBalance = address(this).balance;
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            s_funderToAmountFundedWithEth[funder] = 0;
            s_funderToAmountFundedWithEth[funder] = 0;
        }
        funders = new address[](0);

        (bool withdrawSuccess,) = i_owner.call{value: contractBalance}("");
        require(withdrawSuccess, "Withdraw Failed!");

        delete s_listOfFunders;
        s_totalFundsInEth = 0;
        s_totalFundsInUsd = 0;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getMinEthAmount() public pure returns (uint256) {
        return MINIMUM_ETH;
    }

    function getMinUsdAmount() public pure returns (uint256) {
        return MINIMUM_USD;
    }

    function getMaxAmountInEth() public pure returns (uint256) {
        return MAXIMUM_ETH;
    }

    function getMaxAmountInUsd() public pure returns (uint256) {
        return MAXIMUM_USD;
    }

    function getFundersLimitNumber() public pure returns (uint256) {
        return MAXIMUM_FUNDERS;
    }

    function getGoalAmounts() public pure returns (uint256, uint256) {
        return (GOAL_IN_ETH, GOAL_IN_USD);
    }

    function getGoalAmountinEth() public pure returns (uint256) {
        return GOAL_IN_ETH;
    }

    function getGoalAmountInUsd() public pure returns (uint256) {
        return GOAL_IN_USD;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_listOfFunders[index];
    }

    function getFunderAmountFundedInEth(address funder) public view returns (uint256) {
        return s_funderToAmountFundedWithEth[funder];
    }

    function getFunderAmountFundedInUsd(address funder) public view returns (uint256) {
        return s_funderToAmountFundedWithUsd[funder];
    }

    function getTotalFundsInEth() public view returns (uint256) {
        return s_totalFundsInEth;
    }

    function getTotalFundsInUsd() public view returns (uint256) {
        return s_totalFundsInUsd;
    }

    function getMaxNumberOfFunders() public pure returns (uint256) {
        return MAXIMUM_FUNDERS;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
