// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract ERC1155Auction is ERC1155Holder {

    struct Auction {
        address nft;
        uint256 tokenId;
        uint256 amount;
        address payable owner;
        uint256 startTime;
        uint256 endTime;
        uint256 highestBid;
        address payable highestBidder;
        bool active;
    }
    uint256 auctionCount;
    mapping(uint256 => Auction) public auctions;

    function createAuction(address _nft,uint256 _tokenId,uint256 _amount, uint256 _baseValue, uint256 _startTime, uint256 _endTime) public {
        auctions[_tokenId] = Auction({
            nft:_nft,
            tokenId: _tokenId,
            amount:_amount,
            owner: payable(msg.sender),
            highestBid: _baseValue,
            highestBidder: payable(address(0)),
            startTime: _startTime,
            endTime: _endTime,
            active: true
        });
        ERC1155 nft = ERC1155(_nft);
        nft.safeTransferFrom(msg.sender,address(this),_tokenId,_amount,"");
        auctionCount++;
    }

    function placeBid(uint256 _auctionId) public payable {
        Auction storage auction = auctions[_auctionId];

        require(auction.active && (block.timestamp>auction.startTime && block.timestamp<auction.endTime), "Auction is not active");
        require(msg.value > auction.highestBid, "You must have to pay more that highest bid");

        auction.highestBid = msg.value;
        auction.highestBidder = payable(msg.sender);
    }

    function endAuction(uint256 _auctionId) public{
        Auction storage auction = auctions[_auctionId];
        require(_auctionId <= auctionCount, "Invalid auction ID");
        require(msg.sender == auction.owner, "Only owner can end auctions");
        require(block.timestamp > auction.endTime , "Auction has not yet ended");    
        auction.active = false;
    }

    function transferNFT(uint256 _auctionId) public payable{
        Auction storage auction = auctions[_auctionId];
        require(!auction.active, "Auction has already ended");
        require(msg.sender==auction.owner);
        ERC1155 nft = ERC1155(auction.nft);

        if (auction.highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), auction.highestBidder, auction.tokenId,auction.amount,"");
            auction.owner.transfer(auction.highestBid);
        }
        else{
            nft.safeTransferFrom(address(this), auction.owner, auction.tokenId,auction.amount,"");
        }
    }
}
