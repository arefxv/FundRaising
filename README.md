# FundRaising Smart Contract Suite 📜

Welcome to the **FundRaising Smart Contract Suite**, a robust and scalable solution for decentralized crowdfunding. This suite supports contributions in both **ETH** and **USD**, offers customizable funding goals, and ensures only authorized withdrawals by the contract owner.

Designed with **Foundry**, this repository includes core contracts, deployment scripts, and comprehensive tests, ensuring flexibility, security, and reliability. Whether you're building a fundraising platform, DAO treasury, or blockchain-based charity, this implementation provides a solid foundation.

---
## Table of Contents
1. Introduction
2. Key Features
3. Setup Instructions
4. Contract Overview
   - FundRaising Contract
   - HelperConfig
5. Interaction Scripts
   - Funding (ETH/USD)
   - Withdrawals
6. Testing Suite
6. Future Enhancements

---

## Introduction
The **FundRaising Smart Contract Suite** aims to simplify the creation of blockchain-based fundraising projects. With dual-currency support, contributors can fund projects using ETH or equivalent USD, calculated using real-time price feeds. Additionally, the contract includes safeguards like minimum/maximum contribution limits, funding caps, and contributor tracking to ensure transparency and reliability.

This repository is powered by **Foundry**, a powerful Ethereum development framework, offering tools for contract testing, deployment, and scripting.

---

## Key Features
- Dual Currency Support: Accepts contributions in ETH and USD, ensuring flexibility for users.
- Custom Funding Goals: Define funding goals in ETH and USD, with automatic tracking of progress.
- Contributor Safeguards:
    - Enforces minimum and maximum contribution limits.
    - Stops contributions once the funding goal is met.
    - Restricts the maximum number of contributors.
- Secure Withdrawals: Allows only the contract owner to withdraw funds once goals are achieved.
- Comprehensive Testing: Includes edge cases and failure scenarios for maximum reliability.
- Dynamic Configuration: Adapts seamlessly to different chains like Mainnet, Sepolia, and local networks.

---

## Setup Instructions
1. **Prerequisites**:

    - Install Foundry.
    - Ensure you have a compatible Ethereum wallet and a funded test account.
2. **Clone the Repository**:

```bash
git clone <repository_url>
cd <repository_name>
```
3. **Install Dependencies**:

```bash
forge install
```
4. **Run Tests**: Verify the implementation using Foundry’s testing framework:

```bash
forge test
```
5. **Deploy the Contract**: Use the provided deployment scripts:

```bash
forge script script/DeployFundRaising.s.sol -rpc-url <rpc_url> --private-key <private_key> --broadcast 
```

---

## Contract Overview
### FundRaising Contract
The `FundRaising` contract is the core component of this suite. It handles contributions, tracks funding progress, and manages withdrawals.

### Key Methods:
1. **Funding in ETH**:

```solidity
function fundWithEth() public payable;
```

Accepts ETH contributions, enforcing minimum and maximum limits.

2. **Funding in USD**:

```solidity
function fundWithUsd() public payable;
```
Accepts USD contributions, converted using the chain's price feed.

3. **Withdrawals**:

```solidity
function withdraw() external;
```
Allows only the owner to withdraw funds once the goal is reached.

4. **Funding Limits**:

    + `getMinEthAmount()`: Returns the minimum ETH contribution.
    + `getMinUsdAmount()`: Returns the minimum USD contribution.
    + `getMaxAmountInEth()`: Returns the maximum ETH contribution.
    + `getMaxAmountInUsd()`: Returns the maximum USD contribution.

---
## HelperConfig
The `HelperConfig` contract centralizes network configuration, adapting the deployment to Mainnet, Sepolia, or a local environment.

**Core Methods**:

  + `getConfigByChainId(uint256 chainId)`: Returns configuration details (e.g., price feed) for the specified chain.
  
+ **Mock Price Feed**:

  + Simulates USD price feeds in local development environments.
---

## Interaction Scripts

The interaction scripts simplify interaction with the `FundRaising` contract for funding and withdrawal operations.

### Funding (ETH/USD)

#### ETH Funding:

Script: `FundFundRaisingInEth`

```solidity
function fundFundRaisingInEth(address mostRecentlyDeployed) public {
    FundRaising(payable(mostRecentlyDeployed)).fundWithEth{value: SEND_VALUE}();
}
```

- Sends ETH to the contract, ensuring contribution limits are met.

#### USD Funding:
Script: `FundFundRaisingInUsd`

```solidity
function fundFundRaisingInUsd(address mostRecentlyDeployed) public {
    FundRaising(payable(mostRecentlyDeployed)).fundWithUsd{value: SEND_VALUE}();
}
```

- Sends USD-equivalent funds to the contract.


### Withdrawals

#### Withdraw Script:

Script: `WithdrawFundRaising`

```solidity
function withdrawFundRaising(address mostRecentlyDeployed) public {
    FundRaising(payable(mostRecentlyDeployed)).withdraw();
}
```

- Allows the owner to withdraw funds once the goal is achieved.
---

## Testing Suite

The project includes an extensive suite of tests to ensure reliability under various conditions. All tests are implemented using Foundry’s `Test` module.

### Key Test Cases

#### Basic Validations

 + **Minimum/Maximum Contributions**:
    + `testFundWithEthFailsIfMinEthIsNotMet`
    + `testFundWithUsdFailsIfMinUsdIsNotMet`
  
 + **Goal Validation**:
    + `testFundWithEthFailsIfGoalHasBeenReached`
    + `testFundWithUsdFailsIfGoalHasBeenReached`

 #### Edge Cases

 + **Maximum Contributors**:
    + `testFundFailsWhenFundingIsFull``
 + **Invalid Configurations**:
    + testGetConfigByInvalidChainId

#### Withdrawal Logic

+ Validates correct behavior when funds are withdrawn by the owner.
+ Ensures balances update accurately after withdrawal.

### Mock Price Feed

Tests the integration of the mock price feed for local environments.

### Run Tests:

```bash
forge test
```

---
## Future Enhancements

1. **Additional Payment Options**:

    - Integrate other stablecoins (e.g., USDT, USDC) for funding.

2. **Advanced Withdrawal Logic**:

    - Add support for milestone-based withdrawals.

3. **Dynamic Goal Adjustments**:

    - Enable the owner to update funding goals mid-campaign.

4. **Cross-Chain Support**:

    - Expand functionality to handle contributions across multiple chains.

5. **UI Integration**:

    - Develop a front-end interface for easier interaction.

---

## Conclusion

The **FundRaising Smart Contract Suite** provides a robust framework for decentralized crowdfunding. With dual-currency support, flexible funding goals, and secure withdrawals, it is well-suited for a variety of blockchain-based fundraising applications. Designed with Foundry, the suite ensures reliability and scalability, empowering developers to create impactful projects in the Web3 ecosystem.

For questions, feedback, or contributions, feel free to open an issue or submit a pull request. 🚀



