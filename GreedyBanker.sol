// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// created by u/too_much_hopium user in the reddit discussion:
// https://www.reddit.com/r/solidity/comments/13gzpob/new_solidity_dev_code_review/?utm_source=share&utm_medium=web2x&context=3

contract GreedyBanker {
    struct Account {
        bool freebieUsed;
        uint256 balance;
    }
    address private banker;
    mapping(address => Account) bank;
    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);
    event FeesCollected(address indexed by, uint256 amount);

    constructor() {
        banker = msg.sender;
    }

    receive() external payable {
        if (bank[msg.sender].freebieUsed) {
            require(
                msg.value > 1000 wei,
                "Deposit must be greater than 1000 wei."
            );
            bank[banker].balance += 1000;
            bank[msg.sender].balance += (msg.value - 1000);
        } else {
            bank[msg.sender].freebieUsed = true;
            bank[msg.sender].balance += msg.value;
        }
        emit Deposit(msg.sender, msg.value);
    }

    fallback() external payable {
        bank[banker].balance += msg.value;
        if (!bank[msg.sender].freebieUsed) {
            bank[msg.sender].freebieUsed = true;
        }

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(
            bank[msg.sender].balance >= amount,
            "You cannot withdraw more than your current balance."
        );
        bank[msg.sender].balance -= amount;
        (bool withdrawn, ) = payable(msg.sender).call{value: amount}("");
        require(withdrawn, "Withdrawal failed, reverting transaction.");
        emit Withdraw(msg.sender, amount);
    }

    function collectFees() external {
        require(msg.sender == banker, "You are not the bank manager.");
        uint256 oldBalance = bank[banker].balance;
        bank[banker].balance = 0;
        (bool collected, ) = payable(banker).call{value: oldBalance}("");
        require(collected, "Collection failed, reverting transaction.");
        emit FeesCollected(banker, oldBalance);
    }

    function getBalance() public view returns (uint256) {
        require(
            bank[msg.sender].freebieUsed || msg.sender == banker,
            "You have no active account with this bank."
        );
        return bank[msg.sender].balance;
    }
}
