// SPDX-License-Identifier: MIT
pragma solidity  >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ICO3{
    uint256 counter;
    mapping(uint256=> IcoInfo) icoNumber;

    struct IcoInfo{
        ERC20 token;
        address owner;
        uint256 startTime;
        uint endTime;
        uint256 pricePerToken;
    }

    function createIco(address _token, uint256 _amount, uint256 _startTime, uint256 _endTime, uint256 _pricePerToken) public returns(uint256){    
        counter++;
        require(_endTime>_startTime && _pricePerToken!=0,"EndTime should be greater then StartTime and also price per token should be positive and non-zero!");
        icoNumber[counter]=IcoInfo(ERC20(_token),msg.sender,_startTime,_endTime,_pricePerToken);
        ERC20(_token).transfer(address(this), _amount);
        return counter;    
    }

    function invest(uint256 _icoNum) public payable returns(uint256 _applicableTokens){
        IcoInfo memory currentIco=icoNumber[_icoNum];
        uint256 currentAmount=currentIco.token.balanceOf(address(this));
        require(currentIco.startTime < currentIco.endTime, "ICO is closed");
        require(currentAmount > 0, "ICO is sold out");
        uint256 desiredTokens = (msg.value / currentIco.pricePerToken) * 10**18;//0.01-1
                                                                             //msg.value
        if (currentAmount >= desiredTokens) {
            //provide desired tokens
            uint256 totalPrice = currentIco.pricePerToken * desiredTokens / 10**18;
            require(msg.value >= totalPrice, "Please enter appropriate fees");//1 wei*1 token
            payable(currentIco.owner).transfer(msg.value);//payment to owner
            currentIco.token.transfer(msg.sender, desiredTokens);//tokens transfer to the investor
           return desiredTokens;
        } else {
            //provide applicable tokens 
            uint256 applicableTokenPrice=(currentIco.pricePerToken * currentAmount) / 10**18; //5
            uint256 refund = msg.value - applicableTokenPrice;//7-5 =2
            payable(currentIco.owner).transfer(applicableTokenPrice);//pay price to owner
            currentIco.token.transfer(msg.sender,currentAmount);//provide all tokens
            payable(msg.sender).transfer(refund);
            return currentAmount;
        }
        
    } 
}
