// SPDX-License-Identifier: MIT
pragma solidity  >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTAuction{
    address payable public owner; 
    uint public startTime; 
    uint public endTime;  
    address public highestBidder; 
    uint public highestBid; 
    uint256 public nftId;
    ERC721 public nft;
    
    mapping(address => uint) public bids; // mapping of all bidders and their bids

    event NewHighestBid(address bidder, uint amount);

    modifier auctionRunning(){
        require(block.timestamp >= startTime && block.timestamp <= endTime,"Auction is not Active!");
        _;
    }
    modifier auctionEnded(){
        require(block.timestamp > endTime,"Auction is Still Running!");
        _;
    }

    constructor(uint _startTime, uint _endTime, uint _baseValue, uint256 _nftId, address _nft) {
        owner = payable(msg.sender);
        startTime = _startTime;
        endTime = _endTime;
        highestBid = _baseValue *(10**18);
        nftId=_nftId;
        nft=ERC721(_nft);
        nft.safeTransferFrom(msg.sender,address(this),_nftId);
    }
    
    function placeBid() public payable auctionRunning(){
        require(msg.value > highestBid, "Bid must be greater than Highest Bid");
        highestBidder = msg.sender;
        highestBid = msg.value;
        bids[msg.sender] += msg.value;
      
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function transferNFTToWinner() public payable auctionEnded(){
        require(msg.sender==owner);
        if (highestBidder != address(0)) {
            nft.transferFrom(address(this),highestBidder,nftId);
            owner.transfer(highestBid);
        }
    }  

    function withdrawBids() public payable auctionEnded(){
        require(bids[msg.sender]>0,"You have not enough bids to withdraw");
        payable(msg.sender).transfer(bids[msg.sender]);
        delete bids[msg.sender];
    }
}
