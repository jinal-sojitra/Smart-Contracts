// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ICOFactory {
    uint256 public counter;
    mapping(uint256 => address) public icos;
  
    function createIco(address _token, uint256 _amount,uint256 _startTime, uint256 _endTime, uint256 _pricePerToken) public{
        counter++;
        ICO newIco = new ICO(_token,msg.sender, _startTime, _endTime, _pricePerToken);
        icos[counter] = address(newIco);
        ERC20(_token).transferFrom(msg.sender, address(newIco), _amount);
    }

    function invest(uint256 _icoNum) public payable returns (uint256 _applicableTokens) {
        ICO currentIco = ICO(icos[_icoNum]);
        uint256 currentAmount = currentIco.token().balanceOf(icos[counter]);
        require(currentIco.startTime() < currentIco.endTime(), "ICO is closed");
        //require(currentAmount > 0, "ICO is sold out");
        uint256 desiredTokens = (msg.value / currentIco.pricePerToken()) * 10**18; // 0.01-1 msg.value
        // require(desiredTokens > 0, "Invalid token amount");

        if (currentAmount >= desiredTokens) {
            //provide desired tokens
            payable(currentIco.icoCreator()).transfer(msg.value); //payment to owner
            currentIco.transferToken(msg.sender, desiredTokens); //tokens transfer to the investor
            return desiredTokens;
        } else {
            //provide applicable tokens 
            uint256 applicableTokenPrice = (currentIco.pricePerToken() * currentAmount) / 10**18; // 5
            uint256 refund = msg.value - applicableTokenPrice; // 7-5 = 2
            payable(currentIco.icoCreator()).transfer(applicableTokenPrice); //pay price to owner
            currentIco.transferToken(msg.sender, currentAmount); //provide all tokens
            payable(msg.sender).transfer(refund);
            return currentAmount;
        }
    }
}

contract ICO {
    ERC20 public token;
    address public owner;
    address public icoCreator;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public pricePerToken;

    constructor(address _token,address _icoCreator, uint256 _startTime, uint256 _endTime, uint256 _pricePerToken) {
        require(_endTime > _startTime && _pricePerToken > 0, "Invalid parameters");
        token = ERC20(_token);
        owner = msg.sender;
        icoCreator = _icoCreator;
        startTime = _startTime;
        endTime = _endTime;
        pricePerToken = _pricePerToken;
        
    }

    function transferToken(address to,uint256 amount) external {
        require(msg.sender == owner);
        token.transfer(to,amount);
    }
}
