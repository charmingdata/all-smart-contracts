// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Belongs to muratcan-yuksel and it's part of their video tutorial -- https://www.youtube.com/watch?v=jr7MoX30IAQ&t=2903s
// Github: https://github.com/muratcan-yuksel/marketing-referral/blob/main/backend/contracts/Referral.sol

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//import hardhat console log
import "hardhat/console.sol";

contract Referral is ReentrancyGuard {
    using SafeMath for uint256;
    struct User {
        address referrer;
        uint8 totalReferrals;
        uint8 level;
        uint256 earnings;
    }

    address public owner;
    mapping(address => User) public users;

    uint256 public constant REGISTRATION_FEE = 0.25 ether;
    uint8 public constant REFERRAL_PERCENTAGE = 70;
    uint8 public constant BONUS_REFERRALS = 2;
    uint8 public constant BONUS_PERCENTAGE = 50;

    constructor() {
        owner = msg.sender;
        // User storage firstUser = users[owner];
        //set the first user as deployer
        users[owner] = User(address(0), 0, 1, 0);
        // firstUser.referrer = address(0);
        // firstUser.totalReferrals = 0;
        // firstUser.level = 1;
        // firstUser.earnings = 0;
    }

    modifier validRegistration(address _referrer) {
        require(
            msg.value == REGISTRATION_FEE,
            "Registration fee is 0.25 ether"
        );
        require(
            users[msg.sender].referrer == address(0),
            "User already registered"
        );
        require(
            _referrer != address(0) && _referrer != msg.sender,
            "Invalid referrer"
        );
        if (_referrer != owner) {
            require(
                users[_referrer].referrer != address(0),
                "Referrer does not exist"
            );
        }
        require(
            users[_referrer].referrer != msg.sender,
            "Referrer cannot be the sender"
        );

        //require that the referrer has referrer less than 9 people
        require(
            users[_referrer].totalReferrals < 9,
            "Referrer has already referred 9 people"
        );
        //require that the referrer is less than 10 levels
        require(users[_referrer].level < 10, "Referrer is already at level 10");
        _;
    }

    function register(
        address _referrer
    ) public payable validRegistration(_referrer) {
        User storage newUser = users[msg.sender];
        newUser.referrer = _referrer;
        newUser.totalReferrals = 0;
        newUser.level = 1;

        // console.log("User registered: %s", msg.sender);
        // console.log("Referrer: %s", _referrer);
        // console.log(msg.value);

        transferPayment(_referrer, msg.value);
        updateReferralCount(_referrer);
    }

    function transferPayment(address _referrer, uint256 _amount) private {
        uint256 referralAmount = (_amount * REFERRAL_PERCENTAGE) / 100;
        uint256 businessAmount = _amount - referralAmount;
        // console.log("referral", referralAmount);
        // console.log("biz", businessAmount);
        if (
            users[_referrer].totalReferrals > 1 &&
            (users[_referrer].totalReferrals + 1) % 3 == 0
        ) {
            referralAmount = (_amount * BONUS_PERCENTAGE) / 100;
            businessAmount = _amount - referralAmount;
        }
        payable(_referrer).transfer(referralAmount);
        //update earnings
        users[_referrer].earnings += referralAmount;
        //business amount should be sent to the owner/ no, it should be sent to the contract

        // payable(owner).transfer(businessAmount);
    }

    function updateReferralCount(address _referrer) private {
        users[_referrer].totalReferrals++;
    }

    function getUserBalance(address userAddress) public view returns (uint256) {
        return users[userAddress].earnings;
    }

    function getUserLevel(address userAddress) public view returns (uint8) {
        return users[userAddress].level;
    }

    function getUserReferrals(address userAddress) public view returns (uint8) {
        return users[userAddress].totalReferrals;
    }

    function getUserReferrer(
        address userAddress
    ) public view returns (address) {
        return users[userAddress].referrer;
    }

    //if the user has referred 9 people, they can call this function to pay 0.5 eth to the contract and level up
    function levelUp() public payable {
        //require that the user has referred 9 people
        require(
            users[msg.sender].totalReferrals == 9,
            "User has not referred 9 people"
        );
        //require that the user has paid 0.5 eth to the contract
        require(msg.value == 0.5 ether, "User has not paid 0.5 ether");
        //require that the user is less than 9 levels
        require(users[msg.sender].level < 10, "User is already at level 10");
        //update the user's level
        users[msg.sender].level++;
        //update the user's total referrals
        users[msg.sender].totalReferrals = 0;
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    fallback() external payable {
        revert("Invalid function call");
    }

    receive() external payable {
        revert("Received ether without a function call");
    }
}
