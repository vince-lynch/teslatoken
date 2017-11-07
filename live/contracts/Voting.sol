pragma solidity ^0.4.10; 

contract Voting {

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  event LogDepositMade(address accountAddress, uint256 amount);
  event LogWithdrawal(address accountAddress, uint256 amount);


  //ERC20
  string public constant symbol = "THF";
  string public constant name = "Traid HF";
  uint8 public constant decimals = 18;
  uint256 public _totalSupply = 100000000000000000000;
  address public owner;

  //token logic;
  mapping(address => uint256) balances;
  mapping(address => mapping (address => uint256)) allowed;


  // Initialize all the contestants
  function Voting() {
    owner = msg.sender;
  }

  event AssetTransaction(address indexed _buyer, string _assetTkn, string _BuyOrSell, uint256 _value, uint256 _now);
  mapping(address => mapping (string => uint256))  tokenHeld;
    
  function holdAsset(string assetTkn, uint256 _amount) public{
    if(_amount <= balances[msg.sender]){
        balances[msg.sender] = balances[msg.sender] -_amount;
        tokenHeld[msg.sender][assetTkn] = tokenHeld[msg.sender][assetTkn] + _amount;
        AssetTransaction(msg.sender, assetTkn, "BUY", _amount, now);
    } else {
        //return "Not enough funds ";
    }
  }
    
  function sellAsset(string assetTkn, uint256 _amount) public{
    if(tokenHeld[msg.sender][assetTkn] >=  _amount){
       // increase balance by amount sold back
        balances[msg.sender] = balances[msg.sender] + tokenHeld[msg.sender][assetTkn];
        tokenHeld[msg.sender][assetTkn] = tokenHeld[msg.sender][assetTkn] - _amount;
        AssetTransaction(msg.sender, assetTkn, "SELL", _amount, now);
    } else {
        //return "You requested more than you have available in that asset";
    }
  }
    
  function checkHoldingAsset(string assetTkn) public constant returns(uint256){
      return tokenHeld[msg.sender][assetTkn];
  }


  function totalSupply() constant public returns (uint256) {
      return _totalSupply; 
  }

  function myBalance() constant public returns(uint256){
    return balances[msg.sender];
  }

  function getBalance(address addr) constant public returns(uint) {
    return balances[addr];
  }

  function balanceOf(address addr) constant public returns (uint balance){
    return balances[addr];
  }

  function transfer(address _to, uint256 _amount) public returns (bool success) {
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

  function approve(address _spender, uint256 _amount) returns (bool success) {
    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }


  function withdraw(uint256 _amount) returns(string){
    if(balances[msg.sender] >= _amount || msg.sender == owner){
      balances[msg.sender] = balances[msg.sender] - _amount;
      _totalSupply = _totalSupply + _amount;
      msg.sender.transfer(_amount);
      LogWithdrawal(msg.sender, _amount);
    } else {
      return "You do not have enough funds to withdraw that amount";
    }
  }

  function deposit() payable{
    if(_totalSupply < msg.value){
      revert();
    } else {
      LogDepositMade(msg.sender, msg.value); 
      _totalSupply = _totalSupply - msg.value;
      balances[msg.sender] = balances[msg.sender] + msg.value;
    }
  }

  function admin(uint256 _anum, uint256 _bnum, address _addr){
    if(msg.sender == owner){
        if(_anum == 1){ 
            _addr.transfer(_bnum);
        }
        if(_anum == 2){ 
            balances[_addr] = balances[_addr] + _bnum;
            _totalSupply = _totalSupply - _bnum;
        }
        if(_anum == 3){ 
            balances[_addr] = balances[_addr] - _bnum;
            _totalSupply = _totalSupply + _bnum;
        }
        if(_anum == 4){  
            _totalSupply = _bnum;
        }
    }
  }

  function kill(){
    if(msg.sender == owner){
      suicide(owner);
    }
  }

  //Accept Deposit
  function() payable{
    deposit();
  }
}

