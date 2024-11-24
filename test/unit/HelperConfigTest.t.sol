// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {MockV3Aggregator} from "../../test/mocks/MockV3Aggregator.sol";

contract HelperConfigTest is Test {
    HelperConfig public helperConfig;
    MockV3Aggregator public mockPriceFeed;

    address public deployer = address(0x123);

    function setUp() public {
        // Deploy HelperConfig contract
        helperConfig = new HelperConfig();
    }

    function testGetConfigByChainIdMainnet() public {
        // Simulate Mainnet configuration
        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(1);
        assertEq(config.priceFeed, helperConfig.getEthMainnetConfig().priceFeed);
    }

    function testGetConfigByChainIdSepolia() public {
        // Simulate Sepolia configuration
        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(11155111);
        assertEq(config.priceFeed, helperConfig.getSepoliaEthConfig().priceFeed);
    }

    function testGetConfigByChainIdLocal() public {
        // Simulate local network configuration
        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(31337);

        // Ensure mock price feed is deployed and the address is correct
        assertTrue(config.priceFeed != address(0));
        mockPriceFeed = MockV3Aggregator(config.priceFeed);
        assertEq(mockPriceFeed.decimals(), 8);
        assertEq(mockPriceFeed.latestAnswer(), 2000e8);
    }

    function testGetConfigByInvalidChainId() public {
        vm.expectRevert(HelperConfig.HelperConfig__InvalidChainId.selector);
        helperConfig.getConfigByChainId(999999); // Invalid chain ID
    }
}
