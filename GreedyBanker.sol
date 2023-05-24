// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

// The original contract can be found in the reddit link below. But it has been thoroughly modified.
// https://www.reddit.com/r/solidity/comments/13gzpob/new_solidity_dev_code_review/?utm_source=share&utm_medium=web2x&context=3

contract GreedyBanker {
    struct Account {
        bool freebieUsed;
        uint balance;
    }

    address immutable private banker;
    mapping(address => Account) bank;

    constructor() {
        banker = msg.sender;
    }

    receive() external payable {
        if (bank[msg.sender].freebieUsed) {
            require(msg.value > 1000 wei, "Deposit must be greater than 1000 wei.");
            bank[banker].balance += 1000;
            bank[msg.sender].balance += (msg.value - 1000);
        } else {
            bank[msg.sender].freebieUsed = true;
            bank[msg.sender].balance += msg.value;
        }
    }

    fallback() external payable {
        bank[banker].balance += msg.value;
    }

    function withdraw(uint256 amount) external  {
        require(
            bank[msg.sender].balance >= amount,
            "You cannot withdraw more than your current balance."
        );
        bank[msg.sender].balance -= amount;
        payable(msg.sender).transfer(amount);
    }

    function deposit() payable external{
        if (bank[msg.sender].freebieUsed) {
            require(msg.value > 1000 wei, "Deposit must be greater than 1000 wei.");
            bank[banker].balance += 1000; 
            bank[msg.sender].balance += (msg.value - 1000);
        } else {
            bank[msg.sender].freebieUsed = true;
            bank[msg.sender].balance += msg.value;
        }
    }
    function collectFees() external {
        require(msg.sender == banker, "You are not the bank manager.");
        uint oldBalance = bank[banker].balance;
        bank[banker].balance = 0;
        payable(banker).transfer(oldBalance);
    }

    function getBalance() public view returns (uint256) {
        require(bank[msg.sender].freebieUsed || bank[msg.sender].balance >0 || msg.sender == banker,"You have no active account with this bank.");
        return bank[msg.sender].balance;
    }
}
