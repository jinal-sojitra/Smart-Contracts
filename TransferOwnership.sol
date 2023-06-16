// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Ownable{
    address public owner;

    constructor(){
        owner=msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender==owner, "Only owner can access!");
        _;
    }

    function setOwner(address _newOwner) public onlyOwner{
        require(_newOwner != address(0),"Invalid Address");
        owner=_newOwner;
    }

}
