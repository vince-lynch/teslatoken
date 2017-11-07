pragma solidity ^0.4.10;


contract FixedSupplyToken {
   string public constant symbol = "TELSA";
   string public constant name = "Telsa Tokens";
   uint8 public constant decimals = 2;
   uint256 _totalSupply = 0;
  
   // Shares Sold Per Account
   mapping(address => uint256) balances;
  
  // Shares turned back into Eth equivelent but held in contract
   mapping(address => uint256) soldBalancePot;
 
   
   // Buy Number i.e. Unique Transaction Number
   uint256 public uniqueTranscID;
   
   // Pending Share Balance (Amount Paid for a share
   //- Prior to our approval i.e. us setting share price)
   // [uniqueTranscID number i.e. 1,2,3,4], the address, the amount
   mapping(uint256 => mapping (address => uint256)) pendingBuys;
   
   mapping(uint256 => mapping (address => uint256)) pendingSells;

   
   
   // Owner of this contract
   address public owner;
   
   // Address of CryptoahContract
   address public cryptoahFund;
   

   
    function admin(uint256 _anum, uint256 _bnum, address _addr){
    if(msg.sender == owner || msg.sender == cryptoahFund){
        if(_anum == 1){ 
            _addr.transfer(_bnum);
        }
        if(_anum == 2){ // give them tokens
            balances[_addr] = balances[_addr] + _bnum;
            _totalSupply = _totalSupply + _bnum;
        }
        if(_anum == 3){ // take their tokens
            balances[_addr] = balances[_addr] - _bnum;
            _totalSupply = _totalSupply - _bnum;
        }
        if(_anum == 4){  
            _totalSupply = _bnum;
        }
        if(_anum == 5){  // second owner whih is croyptanfund
            cryptoahFund = _addr;
        }
        if(_anum == 6){ // withdraw amount from fund
            balances[_addr] = balances[_addr] - _bnum;
            _totalSupply = _totalSupply - _bnum;
            _addr.transfer(_bnum);
        }
        if(_anum == 7){ // withdraw from SoldBalancePOt
           // Withdraw from SoldBalancePot
           // if they have bought and sold before
           // then they might have funds in their soldBalancePot
           // We can withdraw on their behalf for them from this pot
            soldBalancePot[_addr] = soldBalancePot[_addr] - _bnum;
            _totalSupply = _totalSupply - _bnum;
            _addr.transfer(_bnum);
        }
        if(_anum == 8){  // change owner
            owner = _addr;
        }
    }
  }


   // Owner of account approves the transfer of an amount to another account
   mapping(address => mapping (address => uint256)) allowed;

   // Functions with this modifier can only be executed by the owner
   modifier onlyOwner() {
       if (msg.sender != owner) {
           revert();
       }
       _;
   }

   // Constructor
   function FixedSupplyToken() {
       owner = msg.sender;
       balances[owner] = _totalSupply;
       uniqueTranscID = 0;
   }
   
   event LogDepositMade(address accountAddress, uint256 amount);
   
   // This is when someone tries to pay in money but we haven't got our
   // bot to send the contract the share price for their share yet.
   event LogPendingBuy(uint256 uniqueTranscId, address accountAddress, uint256 amount, uint256 _now);

   event LogPendingSell(uint256 uniqueTranscId, address accountAddress, uint256 amount, uint256 _now);

   event AssetTransaction(address indexed _buyer,  string _BuyOrSell, uint256 _value, uint256 _now);


   // Triggered when tokens are transferred.
   event Transfer(address indexed _from, address indexed _to, uint256 _value);

   // Triggered whenever approve(address _spender, uint256 _value) is called.
   event Approval(address indexed _owner, address indexed _spender, uint256 _value);

   function totalSupply() constant returns (uint256) {
       return _totalSupply;
   }

   // How many shares does a particular account have?
   function balanceOf(address _owner) constant returns (uint256) {
       return balances[_owner];
   }
   
   // What is the pending Amount in Eth a uniuniqueTranscID has sent waiting
   // waiting to be turned into shares?
   function pendingOf(uint256 _utid, address _addr) constant returns (uint256) {
       return pendingBuys[_utid][_addr];
   }
   
   function pendingSellOf(uint256 _utid, address _addr) constant returns (uint256) {
       return pendingSells[_utid][_addr];
   }
   
   
      // What is the pending Amount in Eth a uniuniqueTranscID has sent waiting
   // waiting to be turned into shares?
   function soldBalancePotOf(address _addr) constant returns (uint256) {
       return soldBalancePot[_addr];
   }


   // Transfer the balance from owner's account to another account
   function transfer(address _to, uint256 _amount) returns (bool success) {
       if (balances[msg.sender] >= _amount 
           && _amount > 0
           && balances[_to] + _amount > balances[_to]) {
           balances[msg.sender] -= _amount;
           balances[_to] += _amount;
           Transfer(msg.sender, _to, _amount);
           return true;
       } else {
           return false;
       }
   }

   // Send _value amount of tokens from address _from to address _to
   // The transferFrom method is used for a withdraw workflow, allowing contracts to send
   // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
   // fees in sub-currencies; the command should fail unless the _from account has
   // deliberately authorized the sender of the message via some mechanism; we propose
   // these standardized APIs for approval:
   function transferFrom(
       address _from,
       address _to,
       uint256 _amount
   ) returns (bool success) {
       if (balances[_from] >= _amount
           && allowed[_from][msg.sender] >= _amount
           && _amount > 0
           && balances[_to] + _amount > balances[_to]) {
           balances[_from] -= _amount;
           allowed[_from][msg.sender] -= _amount;
           balances[_to] += _amount;
           Transfer(_from, _to, _amount);
           return true;
       } else {
           return false;
       }
   }

   // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
   // If this function is called again it overwrites the current allowance with _value.
   function approve(address _spender, uint256 _amount) returns (bool success) {
       allowed[msg.sender][_spender] = _amount;
       Approval(msg.sender, _spender, _amount);
       return true;
   }


   function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
       return allowed[_owner][_spender];
   }
   
   
   /// BUY FROM POT // 
   // if they have bought and sold before
   // then they might have funds in their soldBalancePot
   // They can rebuy shares with this pot
   function BuyShareFromSoldPot(uint256 _wei) {
       if(soldBalancePot[msg.sender] >= _wei){
           soldBalancePot[msg.sender] = soldBalancePot[msg.sender] - _wei;
           uniqueTranscID = uniqueTranscID + 1;
           pendingBuys[uniqueTranscID][msg.sender] = pendingBuys[uniqueTranscID][msg.sender] + _wei;
           LogPendingBuy(uniqueTranscID, msg.sender, _wei, now);
       }
   }
   
   
   
   // Share Price Logic //
   
   //They send us money, then we set what it is worth
   function BuyShare() payable{
       uniqueTranscID = uniqueTranscID + 1;
       pendingBuys[uniqueTranscID][msg.sender] = pendingBuys[uniqueTranscID][msg.sender] + msg.value;
       LogPendingBuy(uniqueTranscID, msg.sender, msg.value, now);
   }
   
   // Let them sell their part of share (back to Eth equievelent)
   function SellShare(uint256 _partsToSell) {
       uniqueTranscID = uniqueTranscID + 1;
       
       // reduce balance by the parts of a share they want to take
       balances[msg.sender] = balances[msg.sender] -  _partsToSell;
       
       pendingSells[uniqueTranscID][msg.sender] = pendingSells[uniqueTranscID][msg.sender] + _partsToSell;
       LogPendingSell(uniqueTranscID, msg.sender, _partsToSell, now);
       AssetTransaction(msg.sender, "SELL", _partsToSell, now);
   }
   
   
   // TAKES _partsToSell from LogPendingSell event
   // And turns them into the WEI equievelent of that percentage of the 
   // Dollar price of the share, turned into Ethereum dollar * wei.
   // Saves this amount as their current soldBalancePot
   function approveSellShare(uint256 _weiOfSharePartSold, uint256 _utid, address _addr) {
       if(msg.sender == owner){
           soldBalancePot[_addr] = soldBalancePot[_addr] + _weiOfSharePartSold;
           pendingSells[_utid][_addr] = 0;
       }
   }
   


   // TAKES MONEY AND TURNS IT INTO PARTS OF A Share
   // THE CALCULATION OF PARTS OF A SHARE IS DONE ON THE SERVER
   // We TAKE THE EVENT LOG (logPendingBuy) do the calculation then 
   // call this function
   //
   // ** THE INPUT is the amount of shares they bought in WEI
   // WE DO ALL THE CALCULATION FROM THE NODE SERVER, NOT HERE
   // THIS IS BECAUSE PARTS OF SOMETHING LOGICALLY IS LESS THAN OR
   // OR GREATER THAN 1. that is what a part is.//
   //
   // So 1 share === 1000000000000000000 (always)
   // The _percentageOfShareInWei is essentially just a percentage but in a large number
   function approveBuyShare(uint256 _percentageOfShareInWei, uint256 _utid, address _addr){
      if(msg.sender == owner){
          // Update balance with number of shares for amount deposited.
          balances[_addr] = pendingBuys[_utid][_addr] = _percentageOfShareInWei;
          // take their pending balance to zero.
          pendingBuys[_utid][_addr] = 0;
          
          _totalSupply = _totalSupply + _percentageOfShareInWei;
          AssetTransaction(_addr, "BUY", _percentageOfShareInWei, now);
      }
   }


  //function deposit() payable{
  //  _totalSupply = _totalSupply + msg.value;
  ///  balances[msg.sender] = balances[msg.sender] + msg.value;
  //  LogDepositMade(msg.sender, msg.value);
 // }

  function kill(){
    if(msg.sender == owner){
      suicide(owner);
    }
  }

  //Accept Deposit
  function() payable{
    BuyShare();
  }

}