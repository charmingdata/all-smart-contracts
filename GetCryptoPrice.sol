// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// https://blog.openzeppelin.com/reentrancy-after-istanbul/
// https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
// Import the AggregatorV3Interface interface into our contract.
// Interfaces provide a reusable and customizable approach to programming smart contracts.
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CryptoValue {
    AggregatorV3Interface internal priceFeed;

    // Create the interface object by pointing to the proxy address inside the constructor
    constructor(address AggregatorAddress) {
        /**
        * https://docs.chain.link/data-feeds/price-feeds/addresses#overview
        * For example let's set up the framework to get the ETH price in USD from the Sepolia network:

        * Network: Sepolia (make sure your Metamask wallet is tied to the sepolia network)
        * Data Feed: ETH/USD
        * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        */
        priceFeed = AggregatorV3Interface(AggregatorAddress);
    }

    // All the functions of the AggregatorV3Interface interface imported above
    // https://docs.chain.link/data-feeds/api-reference#functions-in-aggregatorv3interface

    function getDecimals() external view returns (uint8) {
        return priceFeed.decimals();
    }

    // Returns the latest price of a currency
    function getLatestPrice() public view returns (int) {
        ( ,int price, , , ) = priceFeed.latestRoundData();
        return price;
    }

}
