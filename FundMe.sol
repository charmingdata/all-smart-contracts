// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 < 0.9.0;

// Belongs to full-blockchain-solidity-course on YouTube https://www.youtube.com/watch?v=M576WGiDBdQ
// GitHub -- https://github.com/PatrickAlphaC/fund_me


// https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// more docs: https://docs.chain.link/data-feeds/api-reference#latestrounddata-1

contract FundMe {

    mapping(address => uint256) public addressToAmountFunded;
    // we can't loop through a mapping, so we will create an array that
    // we will use to reset everyone's balance inside the mapping to zero after we withdraw everything
    address[] public funders; 

    address public owner;
    constructor() {
        owner = msg.sender;
    }

    // function to accept payment into contract (address)
    function fund() public payable {
        uint256 minimumUsd = 50 * 10 **18;
        require(getConversionRate(msg.value) >= minimumUsd, "You need to send more eth to be more than $49 USD");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);

    }

    // call the version function from the imported interface
    function getVersion() public view returns (uint256) {
        // interface type AggregatorV3Interface, which we we call pricefeed
        // to initiate the interface we need the address of where this is created
        // find sepolia and goerli addresses can be found here: 
        // https://docs.chain.link/data-feeds/price-feeds/addresses/?network=ethereum#overview

        AggregatorV3Interface pricefeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return pricefeed.version();
    }

    // call the latestRoundData function from the imported interface to get latest eth price
    /* 
    function getPrice() public view returns (      
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound) {
        AggregatorV3Interface pricefeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return pricefeed.latestRoundData();
    }
    */

    // same  function as above but returning only the answer (price value) instead of all variable.
        function getPrice() public view returns (uint256) {
        AggregatorV3Interface pricefeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 answer, , , ) = pricefeed.latestRoundData();
        return uint256(answer);
    }

    // convert the eth they send us to usd
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 100000000;
        return ethAmountInUsd;
    }

    function withdraw() payable public {
        require(msg.sender == owner);
        //global transfer function sends crypto from one address to another, specifically msg.sender receives the money
        // this is a keyword in solidity that refers to the contract that we are in
        // when wrapped by address, it means "grab the address of current contract
        payable(msg.sender).transfer(address(this).balance);

        // reset everyone's balance inside the mapping to zero after we withdraw everything
        for(uint256 funderIndex=0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // reset funders array since we only used it to loop over the mapping 
        funders = new address[](0);
    }
    
}
