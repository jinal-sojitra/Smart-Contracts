// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20,Ownable{
    uint256 public constant TAX_RATE=10;//10% tax
    uint256 public constant MIN_INVEST=0.1 ether;
    uint256 public constant MAX_INVEST=2 ether;
    uint256 public MAX_SUPPLY=200000000* (10** uint256(decimals()));
    uint256 public _burnAmount;
    
    // uint256 public constant INITIAL_SUPPLY;
    uint256 public INITIAL_PRICE=10000000*(10**uint256(decimals()));
    mapping(address=>bool) public exemptedAccounts;
    mapping(address=>uint256) public spent;

   
    constructor() ERC20("Jinal's Token","JTT"){
        exemptedAccounts[msg.sender]=true;
    }

    function transfer(address to, uint256 amount) public override returns(bool){
        amount*=10**uint256(decimals());
        uint256 tax = calculateTax(amount);
        uint256 netValue=amount - tax;
        _transfer(msg.sender,to, netValue);
        //tax will be in contract only
        return true;

    }

    function calculateTax(uint256 amount) private view returns(uint256){
        if(exemptedAccounts[msg.sender]){
            return 0;
        }
        return amount*TAX_RATE/100;

    }
    function mint(uint256 amount) public payable onlyOwner(){
        require(totalSupply()+amount<=MAX_SUPPLY,"Max Supply Exeeds!");
        require(amount*(10**uint256(decimals()))/10000000==msg.value,"Please enter appropriate ethers!");
        uint256 tokens = msg.value * INITIAL_PRICE / 1 ether;
        require(totalSupply()+tokens<=MAX_SUPPLY,"No. of tokens exceeded total supply!");
        _mint(msg.sender,tokens);
        
    } 

    function buyTokens() public payable {
        require(msg.value >= MIN_INVEST && spent[msg.sender]+msg.value <= MAX_INVEST, "You can invest 0.1 to 2 ethers only");
        uint256 tokens = msg.value * 10000000;//10000000*10**18 -> 1 ether
                                                                //amount*10**18 -> msg.value
        require(tokens <= balanceOf(owner()), "Insufficient token supply");
        _transfer(owner(), msg.sender, tokens);
    }

    function addExemptedAccount(address account) public onlyOwner {
        exemptedAccounts[account] = true;
    }

    function burn(uint256 amount) public {
        
        _burn(msg.sender, amount*(10** uint256(decimals())));
        _burnAmount += amount;
        
    }
}
