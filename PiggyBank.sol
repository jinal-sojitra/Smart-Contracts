// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PiggyBank is Ownable{

    event Deposit(address depositor, uint256 amount);
    event Withdraw(address withdrawer, uint256 amount);

    receive() external payable {
        emit Deposit(msg.sender,msg.value);
    }

    function withdraw() onlyOwner public{
        emit Withdraw(msg.sender,address(this).balance);
        selfdestruct(payable(msg.sender));
    }
}
