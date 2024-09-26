// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract  CrowdFunding{

//this smart contracts creates multiple compaigns for funding ,multiple people can  create compaigns 


   // mapping(address=>uint) public contributers;
    struct compaign{  
    address  payable  manager;
    string   name;
    uint  deadline;  
    uint  miniminContribution;
    uint   target;
    uint  raisedAmount;
    uint  noOfContributers;
   
    }
        constructor(){}
 mapping(address=>mapping(uint=>uint)) public  contributers;
 // address => compain no  => funds
mapping(uint=>compaign) public compaignNO;
uint id=0; //compain no

mapping (uint=>uint) public voteforno; 
mapping (uint=>uint) public votesforyes;


mapping(address=>mapping(uint=>bool)) public  voter;
//mapping (address=>bool) public voter;
    



//function to create compaing
    function compaign_NO(string memory _name,uint _deadline,uint _target,uint  _raisedAmount,uint  _noOfContributers) public  
    {
      compaignNO[id] = compaign(payable(msg.sender),_name,block.timestamp+_deadline,1 ether,_target,_raisedAmount,_noOfContributers);
           // manager= payable(msg.sender);
           id++;

    }



//function to contribute money 
function donate(uint _id)public payable
{
    require(block.timestamp<compaignNO[_id].deadline,"deadline has crossed");
    require(msg.value>=compaignNO[_id].miniminContribution,"minimum contribution doesnot met");
    if(contributers[msg.sender][_id]==0){
       compaignNO[_id].noOfContributers++; 
    }
    contributers[msg.sender][_id]+=msg.value;
compaignNO[_id].raisedAmount+=msg.value;

}

     
//function for manager to request for votes to get money
function votetosend_Funds(bool _vote,uint _id) public {
require(contributers[msg.sender][_id]>0,"u must contribute to vote");
require(voter[msg.sender][_id]==false,"u have already voted");
require(block.timestamp<compaignNO[_id].deadline,"deadline has passed");
voter[msg.sender][_id]=true;

if(_vote==true){
    votesforyes[_id]++;
}
else{
    voteforno[_id]++;} 
}

//function to send funds to manager
function getfunds(uint _id) public payable returns(string memory){
    require(msg.sender==compaignNO[_id].manager,"u can only get funds for ur compaign only");
require(votesforyes[_id]>voteforno[_id],"people dont trust  you");
require(compaignNO[_id].raisedAmount>=compaignNO[_id].target,"not enough funding");
require(block.timestamp<compaignNO[_id].deadline,"deadline has passed");
compaignNO[_id].manager.transfer(compaignNO[_id].raisedAmount);
compaignNO[_id].raisedAmount=0;
return ("funds have been transferred to ");


}

//returns the total balance of contract
function  totalbalance(uint _id) public  view  returns(uint){
    require(msg.sender==compaignNO[_id].manager,"only manager can check");
    return (address(compaignNO[_id].manager).balance);
}






//function for refunding
function refund(uint _id) public {
    
    require(contributers[msg.sender][_id] > 0, "You did not contribute");
    require(block.timestamp >=compaignNO[_id].deadline, "Deadline has not passed");
    require(compaignNO[_id].raisedAmount < compaignNO[_id].target, "Funds have reached the target, no refunds");

    uint amountToRefund = contributers[msg.sender][_id];
    contributers[msg.sender][_id] = 0;
    compaignNO[_id].raisedAmount -= amountToRefund;

    payable(msg.sender).transfer(amountToRefund);
}

 
    }