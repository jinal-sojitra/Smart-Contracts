// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.2/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.8.2/access/Ownable.sol";

contract MyToken is ERC1155, Ownable {
    uint[] supplies=[50,100,150];
    uint[] minted=[0,0,0];
    uint[] rates=[0.05 ether, 0.1 ether, 0.025 ether];

    constructor() ERC1155("") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(uint256 id, uint256 amount) public payable {
        require( id>0 && id<=supplies.length,"Token Doesn't Exist!");
        uint index=id-1;
        require(minted[index]+amount<=supplies[index],"Total Supply Exceeds");
        require(msg.value>=amount*rates[index],"Not Enough Ethers sent!");
        _mint(msg.sender, id, amount, "");
        minted[index]+=amount;
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function withdraw() public onlyOwner{
        require(address(this).balance>0,"Not enough balance to withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }
}
 
