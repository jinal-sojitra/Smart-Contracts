// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Username{
    //mapping(string=>address) public usernameToAddress;
    mapping(address=>string) public addressToUsername;
    mapping(string=>bool) public usernames;

    function registerUsername(string memory _username) public{
        //if address of corresponding to username is 0 then continue else error msg
        require(!usernames[_username], "This Username Already Reserved by someone else!");
        bytes memory temp=bytes(_username);
        if(bytes(addressToUsername[msg.sender]).length>0) changeUsername(_username);
        require(temp.length>=6 && temp.length<=20, "Username must be of 6 to 20 characters");
        
        //registering
        addressToUsername[msg.sender]=_username;
        usernames[_username]=true;
    }

    function changeUsername(string memory _newUsername) public{
        if(bytes(addressToUsername[msg.sender]).length==0) 
            registerUsername(_newUsername);
        require(!usernames[_newUsername],"This Username Already Reserved by someone else!");
        //change Username
        addressToUsername[msg.sender]=_newUsername;
        delete usernames[addressToUsername[msg.sender]];
        usernames[_newUsername]=true;
    }

    function getUserName() public view returns(string memory){
       return addressToUsername[msg.sender];
    }  
}
