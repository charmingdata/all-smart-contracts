// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// An informative description of Events: https://ethereum.stackexchange.com/a/56880/120832

contract Donation {
    address payable public onlineEducator;

    event LogData(
        uint256 indexed amount,
        string reason,
        address donatorAddress,
        uint256 timestamp
    );

    constructor() payable {
        // Set the Online Educator as the person who instantiated the contract
        onlineEducator = payable(msg.sender);
    }

    function offerDonation(string calldata donationReason) external payable {
        // Emit the event LogData
        emit LogData(msg.value, donationReason, msg.sender, block.timestamp);
        // Send the ether to the Online Educator
        onlineEducator.transfer(msg.value);
    }
}
