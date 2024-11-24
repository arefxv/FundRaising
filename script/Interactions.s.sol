// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {FundRaising} from "../src/FundRaising.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundRaisingInUsd is Script {
    uint256 constant SEND_VALUE = 0.01 ether;
    address FUNDER = makeAddr("funder");

    function fundFundRaisingInUsd(address mostRecentlyDeployed) public {
        FundRaising(payable(mostRecentlyDeployed)).fundWithUsd{value: SEND_VALUE}();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundRaising", block.chainid);
        vm.startBroadcast();
        fundFundRaisingInUsd(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract FundFundRaisingInEth is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundRaisingInEth(address mostRecentlyDeployed) public {
        FundRaising(payable(mostRecentlyDeployed)).fundWithEth{value: SEND_VALUE}();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundRaising", block.chainid);

        vm.startBroadcast();
        fundFundRaisingInEth(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundRaising is Script {
    function withdrawFundRaising(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundRaising(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundRaising", block.chainid);
        withdrawFundRaising(mostRecentlyDeployed);
    }
}
