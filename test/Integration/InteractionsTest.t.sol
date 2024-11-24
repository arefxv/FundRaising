//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {FundFundRaisingInEth, FundFundRaisingInUsd, WithdrawFundRaising} from "../../script/Interactions.s.sol";
import {DeployFundRaising} from "../../script/DeployFundRaising.s.sol";
import {FundRaising} from "../../src/FundRaising.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract InteractionsTest is Test {
    FundRaising fundRaising;
    HelperConfig config;
    DeployFundRaising deploy;
    FundFundRaisingInEth fundFundRaisingInEth;
    FundFundRaisingInUsd fundFundRaisingInUsd;
    WithdrawFundRaising withdrawFundRaising;

    address FUNDER = makeAddr("funder");
    uint256 constant SEND_VALUE = 0.01 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() public {
        deploy = new DeployFundRaising();
        (fundRaising,) = deploy.run();

        vm.deal(FUNDER, STARTING_BALANCE);
    }

    function testFunderCanFundAndOwnerCanWithdraw() public {
        vm.prank(FUNDER);
        fundRaising.fundWithEth{value: SEND_VALUE}();
        fundRaising.fundWithUsd{value: SEND_VALUE}();

        console.log(
            "Contract Balance Before Withdraw:",
            address(fundRaising).balance,
            "Owner Balance Before Withdraw:",
            fundRaising.getOwner().balance
        );
        uint256 contractBalanceBeforeWithdraw = address(fundRaising).balance;
        uint256 ownerBalanceBeforeWithdraw = fundRaising.getOwner().balance;

        vm.prank(fundRaising.getOwner());
        fundRaising.withdraw();

        uint256 contractBalanceAfterWithdraw = address(fundRaising).balance;
        uint256 ownerBalanceAfterWithdraw = fundRaising.getOwner().balance;
        console.log(
            "Contract Balance After Withdraw:",
            address(fundRaising).balance,
            "Owner Balance After Withdraw:",
            fundRaising.getOwner().balance
        );

        assertEq(contractBalanceAfterWithdraw, 0);
        assertEq(ownerBalanceAfterWithdraw, contractBalanceBeforeWithdraw + ownerBalanceBeforeWithdraw);
    }
}
