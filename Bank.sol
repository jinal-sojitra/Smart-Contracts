// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MyBank{
    address public owner;
    uint public fees;
   constructor(){
       owner=msg.sender;
   }

   enum AccountTypes{
       SAVING,
       FIXED,
       CURRENT
   }
   
   //AccountTypes accountType=AccountTypes.SAVING;

   struct accountInfo{
       address _owner;
       uint balance;
       uint accountCreatedTime;
       uint lockPeriod;
       uint accountType;
       bool closed;
       //bool blacklisted;

   }

   mapping(address=>accountInfo) public Account;

   //modifiers
   modifier onlyOwner(){
       require(msg.sender==owner,"Only Owner can access this!");
       _;
   }

   modifier minimum(){
       require(msg.value>=5 ether, "Minimum you have to deposit 5 ether");
       _;
   }

    //Events
    event balanceAdded(address _owner,uint balance,uint timestamp);
    event withdrawalDone(address _owner,uint _amount,uint timestamp);
   
    //account creation
   function createAccount(uint _accountType,uint _lockPeriod) public payable minimum{
       //require(Account[msg.sender].accountCreatedTime==0)
       if(_accountType==0){
           require(msg.value>=5 ether,"Minimum you have to deposit 5 ether");
           Account[msg.sender].lockPeriod=0;
           fees=0;
       }
       else if(_accountType==1){
           require(msg.value>=3 ether,"Minimum you have to deposit 3 ether");
           Account[msg.sender].lockPeriod=block.timestamp+_lockPeriod;
           fees=5 ether;
       }

       Account[msg.sender]._owner=msg.sender;
       Account[msg.sender].accountCreatedTime=block.timestamp;
       Account[msg.sender].closed=false;
       Account[msg.sender].accountType=_accountType;

       uint amt=msg.value-fees;
       Account[msg.sender].balance+=amt;
       Account[owner].balance+=fees;
       emit balanceAdded(msg.sender,msg.value,block.timestamp);
   }

   function deposit() public payable minimum{
       require(Account[msg.sender].accountCreatedTime!=0,"Create your account first");
       require(!Account[msg.sender].closed,"Account is closed, Open your account first!");
       fees=0;
       if(Account[msg.sender].accountType==1){
           fees=5 ether;
       }
       uint amt=msg.value-fees;
       Account[msg.sender].balance+=amt;
       Account[owner].balance+=fees;
       emit balanceAdded(msg.sender, msg.value,block.timestamp);
   }

   //withdraw
   function withdraw(uint _amount) public payable{
       require(Account[msg.sender].accountCreatedTime!=0,"Create your account first!");
       require(!Account[msg.sender].closed,"Account is closed, Open your Account first!");
       if(Account[msg.sender].accountType==1){
           require(Account[msg.sender].lockPeriod<=block.timestamp,"You cannot withdraw the funds with fixed"); 
       }
       require(Account[msg.sender].balance>=_amount,"Not sufficiant balance to withdraw given amount!");
       payable(msg.sender).transfer(_amount);
       Account[msg.sender].balance-=_amount;

       emit withdrawalDone(msg.sender,_amount,block.timestamp);

   }

    function checkBalance() public view returns(uint) {
        return Account[msg.sender].balance;
    }

    function closeAccount() public {
        //code
    }
}
