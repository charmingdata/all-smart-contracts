// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract's comments are from Celo: https://docs.celo.org/blog/using-the-graph

contract SimpleStorage {
    // Define a string called storeTheSentence
    string storeTheSentence;

    constructor(string memory initialSentence) {
        // Set the initial value of storeTheSentence
        storeTheSentence = initialSentence;
    }

    // Declares a function called getSentence
    // The 'public' label means the function can be called internally, by transactions or other contracts
    // The 'view' label indicates that the function does not change the state of the contract
    // The function returns a string from the memory data location
    function getSentence() public view returns (string memory) {
        return storeTheSentence;
    }

    // Declare a function called setSentence
    // The function takes 1 parameter, a string named newSentence, with the calldata data location in the Ethereum Virtual Machine
    // The 'external' label means the function can only be called from an external source
    function setSentence(string calldata newSentence) external {
        // Set the value of storeTheSentence
        storeTheSentence = newSentence;
    }
}
