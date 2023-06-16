// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Lottery{
    address public owner;
    address payable[] public players ;
    uint256 public jackpot;
    uint256 public tickets;
    mapping(address=>bool) public boughtTicket;
    address payable public winner ;

    constructor(){
        owner=msg.sender;
    }

    function buyLottery() payable public{
        require(msg.sender != owner,"Owner can't buy lottery Ticket!");
        require(!boughtTicket[msg.sender],"You already have the Ticket!");
        require(msg.value == 1, "You have to pay 1 ether minimum ");

        players.push(payable(msg.sender));
        boughtTicket[msg.sender]=true;
        jackpot+=msg.value;
        tickets++;
    }

    function random() private view returns(uint256){
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
    }

    function pickWinner() public{
        require(msg.sender==owner,"Only owner can pick the Winner!");
        require(players.length>0,"There are no players to pick from!");

        uint256 index=random()% players.length;
        winner=players[index];

        winner.transfer(jackpot);
        jackpot=0;
        tickets=0;
        delete players;
        //delete boughtTicket;
    }
}
