//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {FundRaising} from "../../src/FundRaising.sol";
import {DeployFundRaising} from "../../script/DeployFundRaising.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract FundRaisingTest is StdCheats, Test {
    FundRaising fundRaising;
    HelperConfig config;
    DeployFundRaising deploy;

    address FUNDER = makeAddr("funder");
    uint256 constant SEND_VALUE = 0.01 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    address USD_FUNDER = makeAddr("usdFunder");
    uint256 constant USD_SEND_VALUE = 0.01 ether;
    uint256 constant USD_STARTING_BALANCE = 5000 ether;
    uint256 constant ETH_TO_USD_RATE = 2000;

    function setUp() public {
        deploy = new DeployFundRaising();
        (fundRaising, config) = deploy.deployer();
        vm.deal(FUNDER, STARTING_BALANCE);
        vm.deal(USD_FUNDER, USD_STARTING_BALANCE);
    }

    function testMinimumEth() public view {
        assertEq(fundRaising.getMinEthAmount(), 1e15);
        console.log("0.001 ETH :", fundRaising.getMinEthAmount());
    }

    function testMinimumUsd() public view {
        assertEq(fundRaising.getMinUsdAmount(), 10e18);
        console.log("10 dollars :", fundRaising.getMinUsdAmount());
    }

    function testMaximumAmountInEth() public view {
        assertEq(fundRaising.getMaxAmountInEth(), 1e17);
        console.log("0.1 ETH :", fundRaising.getMaxAmountInEth());
    }

    function testMaximumAmountInUsd() public view {
        assertEq(fundRaising.getMaxAmountInUsd(), 500e18);
        console.log("500 dollars :", fundRaising.getMaxAmountInUsd());
    }

    function testGoalAmountsAreAccurate() public view {
        (uint256 ethGoal, uint256 usdGoal) = fundRaising.getGoalAmounts();

        assertEq(ethGoal, 1e18);
        assertEq(usdGoal, 2000e18);
        console.log("ETH Goal (1 ETH) :", ethGoal);
        console.log("USD Goal (2000 USD) :", usdGoal);
    }

    function testFundUpdatesFundedDataStructure() public {
        uint256 expectedUsdValue = (USD_SEND_VALUE * ETH_TO_USD_RATE);

        vm.startPrank(FUNDER);
        fundRaising.fundWithEth{value: SEND_VALUE}();
        vm.stopPrank();

        uint256 amountFundedInEth = fundRaising.getFunderAmountFundedInEth(FUNDER);

        vm.startPrank(USD_FUNDER);
        fundRaising.fundWithUsd{value: USD_SEND_VALUE}();
        vm.stopPrank();

        uint256 amountFundedInUsd = fundRaising.getFunderAmountFundedInUsd(USD_FUNDER);

        assertEq(amountFundedInEth, SEND_VALUE);
        console.log("ETH Funder Address :", FUNDER);
        console.log("Amount Funded in ETH with %s ", amountFundedInEth);

        assertEq(amountFundedInUsd, expectedUsdValue);
        console.log("USD Funder Address :", FUNDER);
        console.log("Amount Funded in USD with %s ", amountFundedInUsd);
    }

    function testAddsFunderToArrayOfFunder() public {
        vm.startPrank(FUNDER);
        fundRaising.fundWithEth{value: SEND_VALUE}();
        vm.stopPrank();

        vm.startPrank(USD_FUNDER);
        fundRaising.fundWithUsd{value: USD_SEND_VALUE}();
        vm.stopPrank();

        address firstFunder = fundRaising.getFunder(0);
        address secondFunder = fundRaising.getFunder(1);
        assertEq(firstFunder, FUNDER);
        console.log("First Funder Address Which Funded With ETH:", firstFunder);
        console.log("ETH Amount with %s :", SEND_VALUE);
        assertEq(secondFunder, USD_FUNDER);
        console.log("Second Funder Address Which Funded With USD:", secondFunder);
        console.log("USD Amount with %s :", SEND_VALUE);
    }

    function testFundWithEthFailsIfMinEthIsNotMet() public {
        vm.expectRevert();
        fundRaising.fundWithEth();
    }

    function testFundWithUsdFailsIfMinUsdIsNotMet() public {
        vm.expectRevert();
        fundRaising.fundWithUsd();
    }

    function testFundFailsIfAmountExceedsMax() public {
        uint256 value = 1 ether;
        vm.expectRevert();
        fundRaising.fundWithEth{value: value}();

        vm.expectRevert();
        fundRaising.fundWithUsd{value: value}();
    }

    function testFundWithEthFailsIfGoalHasBeenReached() public {
        uint256 ethGoal = fundRaising.getGoalAmountinEth();
        uint256 singleContribution = 0.1 ether;
        uint256 txCount = ethGoal / singleContribution;

        vm.startPrank(FUNDER);

        for (uint256 i = 0; i < txCount; i++) {
            fundRaising.fundWithEth{value: singleContribution}();
        }
        vm.expectRevert();
        fundRaising.fundWithEth{value: singleContribution}();

        vm.stopPrank();
    }

    function testFundWithUsdFailsIfGoalHasBeenReached() public {
        uint256 usdGoal = fundRaising.getGoalAmountInUsd();
        uint256 singleContributionUsd = 200 * 1e18;
        uint256 ethPrice = ETH_TO_USD_RATE;
        uint256 singleContributionEth = (singleContributionUsd) / ethPrice;

        vm.deal(FUNDER, 10 ether);

        vm.startPrank(FUNDER);

        uint256 txCount = usdGoal / singleContributionUsd;
        for (uint256 i = 0; i < txCount; i++) {
            fundRaising.fundWithUsd{value: singleContributionEth}();
        }

        vm.expectRevert(FundRaising.FundRaising__fundingIsClosed.selector);
        fundRaising.fundWithUsd{value: singleContributionEth}();

        vm.stopPrank();
    }

    function testFundFailsWhenFundingIsFull() public {
        uint256 maxFunders = fundRaising.getMaxNumberOfFunders();
        uint256 sendValue = SEND_VALUE;

        for (uint256 i = 0; i < maxFunders; i++) {
            address funder = address(uint160(i + 1));
            vm.deal(funder, STARTING_BALANCE);
            vm.prank(funder);
            fundRaising.fundWithEth{value: sendValue}();
        }

        address extraFunder = makeAddr("extraFunder");
        vm.deal(extraFunder, STARTING_BALANCE);
        vm.prank(extraFunder);

        vm.expectRevert(FundRaising.FundRaising__fundingIsFull.selector);
        fundRaising.fundWithEth{value: sendValue}();
    }

    function testFunderCanNotWithdraw() public {
        vm.expectRevert();
        fundRaising.withdraw();
    }

    function testPriceFeedSetCorrectly() public {
        address retrievedPriceFeed = address(fundRaising.getPriceFeed());
        address expectedPriceFeed = config.getConfigByChainId(block.chainid).priceFeed;
        assertEq(retrievedPriceFeed, expectedPriceFeed);
    }

    modifier fundedWithEth() {
        vm.prank(FUNDER);
        fundRaising.fundWithEth{value: SEND_VALUE}();
        assert(address(fundRaising).balance > 0);
        _;
    }

    modifier fundedWithUsd() {
        vm.prank(USD_FUNDER);
        fundRaising.fundWithUsd{value: USD_SEND_VALUE}();
        assert(address(fundRaising).balance > 0);
        _;
    }

    function testWithdrawFromSingleFunder() public fundedWithEth fundedWithUsd {
        uint256 contractBalanceBefore = address(fundRaising).balance;
        console.log("Contract balance before: ", contractBalanceBefore);
        uint256 ownerBalanceBefore = fundRaising.getOwner().balance;
        console.log("Owner balance before: ", ownerBalanceBefore);

        vm.startPrank(fundRaising.getOwner());
        fundRaising.withdraw();
        vm.stopPrank();

        uint256 contractBalanceAfter = address(fundRaising).balance;
        console.log("Contract balance after: ", contractBalanceAfter);
        uint256 ownerBalanceAfter = fundRaising.getOwner().balance;
        console.log("Owner balance after: ", ownerBalanceAfter);

        assertEq(contractBalanceAfter, 0);
        assertEq(ownerBalanceAfter, ownerBalanceBefore + contractBalanceBefore);
    }

    function testWithdrawEthFromMultipleFunders() public fundedWithEth {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundRaising.fundWithEth{value: SEND_VALUE}();
        }

        uint256 contractBalanceBefore = address(fundRaising).balance;
        uint256 ownerBalanceBefore = fundRaising.getOwner().balance;

        vm.startPrank(fundRaising.getOwner());
        fundRaising.withdraw();
        vm.stopPrank();

        assert(address(fundRaising).balance == 0);
        assert(contractBalanceBefore + ownerBalanceBefore == fundRaising.getOwner().balance);
        assert((numberOfFunders + 1) * SEND_VALUE == fundRaising.getOwner().balance - ownerBalanceBefore);
    }

    function testWithdrawUsdFromMultipleFunders() public fundedWithUsd {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            hoax(address(i), USD_STARTING_BALANCE);
            fundRaising.fundWithUsd{value: USD_SEND_VALUE}();
        }

        uint256 contractBalanceBefore = address(fundRaising).balance;
        uint256 ownerBalanceBefore = fundRaising.getOwner().balance;

        vm.startPrank(fundRaising.getOwner());
        fundRaising.withdraw();
        vm.stopPrank();

        assert(address(fundRaising).balance == 0);
        assert(contractBalanceBefore + ownerBalanceBefore == fundRaising.getOwner().balance);
        assert((numberOfFunders + 1) * USD_SEND_VALUE == fundRaising.getOwner().balance - ownerBalanceBefore);
    }
}
