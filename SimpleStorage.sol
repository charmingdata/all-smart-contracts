// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract SimpleStorage {
    // Define a string called storeTheSentence. This is a state variable, which will be permanently stored in the blockchain.
    string storeTheSentence;

    constructor(string memory initialSentence) {
        // Assign the value of initialSentence to the storeTheSentence variable
        storeTheSentence = initialSentence;
    }

    // Declares a function called getSentence
    // Solidity funcions visibility: public, private, internal and external
    // Solidity view functions: https://www.geeksforgeeks.org/solidity-view-and-pure-functions/
    function getSentence() public view returns (string memory) {
        return storeTheSentence;
    }

    // Declare a function called setSentence
    // The function takes 1 input parameter, a string named newSentence, with the calldata data location in the Ethereum Virtual Machine
    function setSentence(string calldata newSentence) external {
        // Assign the value of newSentence to the storeTheSentence variable
        storeTheSentence = newSentence;
    }
}
