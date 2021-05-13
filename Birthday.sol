// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "./Ownable.sol";

contract Birthday is Ownable {
    using Address for address payable;
    
    // State variables
    mapping(address => uint256) private _balances;
    address private _birthdayPeople;
    address private _owner;
    uint256 private _birthdayDate;
    uint256 private _deployedTime;
    
    // Events
    event Offered(address indexed sender, uint256 amount);
    event HappyBirthday(address indexed recipient, uint256);

    // constructor
    constructor(address owner_, address birthdayPeople_) Ownable(owner_) {
        require(owner_ != address(0), "Birthday: non-valid address");
        require(birthdayPeople_ != address(0), "Birthday: non-valid address");
        _deployedTime = block.timestamp;
        _birthdayDate = _deployedTime + 120;
        _owner = owner_;
        _birthdayPeople = birthdayPeople_;
    } 

    // modifiers
    modifier OnlyBirthday {
        require(msg.sender == _birthdayPeople, "Birthday: Sorry this gift is not for you!");
        require(block.timestamp >= _birthdayDate,"Birthday: It is not your birthday yet." );
        _;
    }

    // Function
    function offer() external payable {
        require(block.timestamp <= _birthdayDate, "Birthday: Too late to deposit.");
        _offer(msg.sender, msg.value);
    }
    
    receive() external payable {
        _offer(msg.sender, msg.value);
    }
    
    function getGift() public OnlyBirthday {
        require(address(this).balance > 0, "Birthday: can not withdraw 0 ether");
        uint256 amount = address(this).balance;
        payable(msg.sender).sendValue(amount);
        emit HappyBirthday(msg.sender, amount);    }
    
    function total() public view returns (uint256) {
        return address(this).balance;
    }
    
    function yourOffer() public view returns (uint256) {
        return _balances[msg.sender];
    }
    /* 
    function deployedTime() public view returns (uint256) {
        return _deployedTime;
    }
    */
    
    function timeLeft() public view returns (uint256) {
        require(_birthdayDate > block.timestamp, "Time to reclaim the gift.");
        return _birthdayDate - block.timestamp;
    }
    
    function _offer(address sender, uint256 amount) private {
        _balances[sender] += amount;
        emit Offered(sender, amount);
    }
}