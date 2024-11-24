//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {FundRaising} from "../src/FundRaising.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

/**
 * @title DeployFundRaising
 * @author ArefXV
 * @dev A deployment script for the FundRaising contract using Foundry's Script framework.
 * This script also deploys the HelperConfig contract to retrieve the appropriate price feed
 * based on the current network's chain ID.
 */
contract DeployFundRaising is Script {
    /**
     * @notice Deploys the HelperConfig and FundRaising contracts.
     * @dev This function retrieves the price feed address for the current chain
     * and uses it to initialize the FundRaising contract.
     *
     * The function:
     * 1. Deploys the HelperConfig contract.
     * 2. Retrieves the price feed address for the current chain ID.
     * 3. Deploys the FundRaising contract using the retrieved price feed.
     * 4. Returns the deployed FundRaising and HelperConfig contract instances.
     *
     * @return fundRaising The deployed FundRaising contract instance.
     * @return config The deployed HelperConfig contract instance.
     */
    function deployer() public returns (FundRaising, HelperConfig) {
        // Deploy the HelperConfig contract to manage network configurations.
        HelperConfig config = new HelperConfig();

        // Retrieve the appropriate price feed address for the current network.
        address priceFeed = config.getConfigByChainId(block.chainid).priceFeed;

        vm.startBroadcast();
        FundRaising fundRaising = new FundRaising(priceFeed);
        vm.stopBroadcast();

        // Return the deployed contract instances.
        return (fundRaising, config);
    }

    /**
     * @notice Executes the deployment process by calling the deploy function.
     * @dev This function is the entry point when running the script. It calls `deploy()`
     * and returns the deployed contract instances.
     *
     * @return fundRaising The deployed FundRaising contract instance.
     * @return config The deployed HelperConfig contract instance.
     */
    function run() external returns (FundRaising, HelperConfig) {
        return deployer();
    }
}
