// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

/**
 * @title HelperConfig
 *
 * @author ArefXV
 *
 * @dev A contract for managing network configurations, including retrieving price feed addresses for different networks.
 * It supports multiple networks and provides a fallback to mock price feeds for local testing.
 */
contract HelperConfig is Script {
    // Custom error to handle invalid chain IDs.
    error HelperConfig__InvalidChainId();

    /**
     * @notice Struct to store network-specific configurations.
     * @param priceFeed The address of the Chainlink price feed for the respective network.
     */
    struct NetworkConfig {
        address priceFeed;
    }

    // Constants representing price feed addresses for different networks.
    address constant ETH_MAINNET_PRICEFEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address constant SEPOLIA_PRICEFEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address constant BASE_PRICEFEED = 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70;
    address constant LINEA_PRICEFEED = 0x3c6Cd9Cc7c7a4c2Cf5a82734CD249D7D593354dA;

    // Mock price feed parameters for local testing.
    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2000e8; // Mock price in 18-decimal format.

    // Constants representing the chain IDs of supported networks.
    uint256 constant ETH_MAINNET_CHAINID = 1;
    uint256 constant SEPOLIA_CHAINID = 11155111;
    uint256 constant BASE_CHAINID = 8453;
    uint256 constant LINEA_CHAINID = 59144;
    uint256 constant LOCAL = 31337; // Chain ID for local Anvil or Hardhat network.

    // State variable to store the active network configuration.
    NetworkConfig activeNetworkConfig;

    // Mapping of chain IDs to their corresponding network configurations.
    mapping(uint256 chainId => NetworkConfig) private networkConfigs;

    /**
     * @notice Retrieves the network configuration for a given chain ID.
     * @dev If the chain ID is unsupported or invalid, it reverts with a custom error.
     * @param chainId The chain ID for which to retrieve the configuration.
     * @return The NetworkConfig struct containing the price feed address.
     */
    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].priceFeed != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == ETH_MAINNET_CHAINID) {
            return getEthMainnetConfig();
        } else if (chainId == SEPOLIA_CHAINID) {
            return getSepoliaEthConfig();
        } else if (chainId == BASE_CHAINID) {
            return getBaseEthConfig();
        } else if (chainId == LINEA_CHAINID) {
            return getLineaEthConfig();
        } else if (chainId == LOCAL) {
            return getOrCreateAnvilConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    /**
     * @notice Returns the configuration for Ethereum Mainnet.
     * @return The NetworkConfig struct for Ethereum Mainnet.
     */
    function getEthMainnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({priceFeed: ETH_MAINNET_PRICEFEED});
    }

    /**
     * @notice Returns the configuration for Sepolia testnet.
     * @return The NetworkConfig struct for Sepolia.
     */
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({priceFeed: SEPOLIA_PRICEFEED});
    }

    /**
     * @notice Returns the configuration for Base network.
     * @return The NetworkConfig struct for Base.
     */
    function getBaseEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({priceFeed: BASE_PRICEFEED});
    }

    /**
     * @notice Returns the configuration for Linea network.
     * @return The NetworkConfig struct for Linea.
     */
    function getLineaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({priceFeed: LINEA_PRICEFEED});
    }

    /**
     * @notice Creates and returns a mock configuration for local testing.
     * @dev Deploys a mock price feed contract if it doesn't already exist.
     * @return The NetworkConfig struct containing the mock price feed address.
     */
    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast(); // Starts a broadcasting session for deployment.
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE); // Deploy mock price feed.
        vm.stopBroadcast(); // Ends the broadcasting session.
        activeNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return activeNetworkConfig;
    }
}
