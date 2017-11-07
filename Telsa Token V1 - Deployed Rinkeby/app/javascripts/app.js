// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

/*
 * When you compile and deploy your Voting contract,
 * truffle stores the abi and deployed address in a json
 * file in the build directory. We will use this information
 * to setup a Voting abstraction. We will use this abstraction
 * later to create an instance of the Voting contract.
 * Compare this against the index.js from our previous tutorial to see the difference
 * https://gist.github.com/maheshmurthy/f6e96d6b3fff4cd4fa7f892de8a1a1b4#file-index-js
 */

import voting_artifacts from '../../build/contracts/Voting.json'

var Voting = contract(voting_artifacts);

let candidates = {"Rama": "candidate-1", "Nick": "candidate-2", "Jose": "candidate-3"}

// window.voteForCandidate = function(candidate) {
//   let candidateName = $("#candidate").val();
//   try {
//     $("#msg").html("Vote has been submitted. The vote count will increment as soon as the vote is recorded on the blockchain. Please wait.")
//     $("#candidate").val("");

//      Voting.deployed() returns an instance of the contract. Every call
//      * in Truffle returns a promise which is why we have used then()
//      * everywhere we have a transaction call
     
//     Voting.deployed().then(function(contractInstance) {
//       contractInstance.voteForCandidate(candidateName, {gas: 140000, from: web3.eth.accounts[0]}).then(function() {
//         let div_id = candidates[candidateName];
//         return contractInstance.totalVotesFor.call(candidateName).then(function(v) {
//           $("#" + div_id).html(v.toString());
//           $("#msg").html("");
//         });
//       });
//     });
//   } catch (err) {
//     console.log(err);
//   }
// }

window.setString = function(_string) {
  Voting.deployed().then(function(contractInstance) {
    contractInstance.setString(_string, {gas: 140000, from: web3.eth.accounts[0]}).then(function() {
      contractInstance.someString.call().then(function(v) {
        console.log('somestring is:', v.toString());
      });
    });
  });
}

window.getString = function(){
    Voting.deployed().then(function(contractInstance) {
    contractInstance.getString.call().then(function(v) {
      console.log('getString is:', v);
    });
  });
}

window.getERC20 = function(){

    Voting.deployed().then(function(contractInstance) {
    contractInstance.symbol.call().then(function(v) {
      console.log('erc20 symbol is:', v);
    });
    contractInstance.name.call().then(function(v) {
      console.log('erc20 name is:', v);
    });
    contractInstance.decimals.call().then(function(v) {
      console.log('erc20 decimals is:', v);
    });
    contractInstance._totalSupply.call().then(function(v) {
      console.log('erc20 _totalSupply is:', v);
    });
    contractInstance.owner.call().then(function(v) {
      console.log('erc20 owner is:', v);
    });
  });
}

// ALL SETTERS NEED GAS
window.withdraw = function(_amount) {
  Voting.deployed().then(function(contractInstance) {
    contractInstance.withdraw(_amount, {gas: 140000, from: web3.eth.accounts[2]}).then(function(v) {
      contractInstance.myBalance.call().then(function(v) {
        console.log('myBalance is:', v.toString());
      });
    });
  });
}

// ALL GETTERS ARE CONSTANTS
window.getBalance = function(_address) {
  Voting.deployed().then(function(contractInstance) {
    contractInstance.getBalance.call(_address).then(function(v) {
      console.log('_address Balance is:', v);
    });
  });
}

window.transferTo = function(_address, _amount) {
  Voting.deployed().then(function(contractInstance) {
    contractInstance.transfer(_address, _amount, {gas: 140000, from: web3.eth.accounts[1]}).then(function() {
      contractInstance.getBalance.call(_address).then(function(v) {
        console.log('Their Balance is:', v);
      });
    });
  });
}

window.killContract = function() {
  Voting.deployed().then(function(contractInstance) {
    contractInstance.kill({gas: 140000, from: web3.eth.accounts[0]}).then(function(v) {
      console.log('contract probably killed');
    });
  });
}

window.changeSupply = function(_amount) {
  Voting.deployed().then(function(contractInstance) {
    contractInstance.admin("4", _amount, "0x5b430ae0158280215ce5ad27f6e48991db374864", {gas: 140000, from: web3.eth.accounts[0]}).then(function(v) {
      contractInstance._totalSupply.call().then(function(v) {
        console.log('erc20 _totalSupply is:', v);
      });
    });
  });
}

window.sendFundsOut = function(_amount, _address) {
  Voting.deployed().then(function(contractInstance) {
    contractInstance.admin("1", _amount, _address, {gas: 140000, from: web3.eth.accounts[0]}).then(function(v) {
      console.log('Recievers balance is now', web3.eth.getBalance(_address));
    });
  });
}

window.checkAsset = function(_assetTkn) {
  Voting.deployed().then(function(contractInstance) {
    contractInstance.checkHoldingAsset.call(_assetTkn).then(function(v) {
      console.log('Holding ', v, "of " + _assetTkn);
    });
  });
}

window.sellAsset = function(_assetTkn, _amount) {
  Voting.deployed().then(function(contractInstance) {
    contractInstance.sellAsset(_assetTkn, _amount, {gas: 140000, from: web3.eth.accounts[2]}).then(function(v) {
      contractInstance.checkHoldingAsset.call(_assetTkn).then(function(v) {
        console.log('Now holding ', v, "of " + _assetTkn);
      });
    });
  });
}

window.buyAsset = function(_assetTkn, _amount) {
  Voting.deployed().then(function(contractInstance) {
    contractInstance.holdAsset(_assetTkn, _amount, {gas: 140000, from: web3.eth.accounts[2]}).then(function(v) {
      contractInstance.checkHoldingAsset.call(_assetTkn).then(function(v) {
        console.log('Now holding ', v, "of " + _assetTkn);
      });
    });
  });
}


window.listenEvents = function(){
  Voting.deployed().then(function(contractInstance) {
    var myEvent = contractInstance.LogDepositMade({some: 'args'}, {fromBlock: 0, toBlock: 'latest'});
    myEvent.watch(function(error, result){
       console.log('LogDepositMade', result);
    });

    var myEvent2 = contractInstance.AssetTransaction({some: 'args'}, {fromBlock: 0, toBlock: 'latest'});
    myEvent2.watch(function(error, result){
       console.log('AssetTransaction', result);
    });

    var myEvent3 = contractInstance.Transfer({some: 'args'}, {fromBlock: 0, toBlock: 'latest'});
    myEvent2.watch(function(error, result){
       console.log('Transfer', result);
    });

    var myEvent4 = contractInstance.LogWithdrawal({some: 'args'}, {fromBlock: 0, toBlock: 'latest'});
    myEvent2.watch(function(error, result){
       console.log('LogWithdrawal', result);
    });
  });
}


$( document ).ready(function() {
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source like Metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  Voting.setProvider(web3.currentProvider);
  let candidateNames = Object.keys(candidates);
  // for (var i = 0; i < candidateNames.length; i++) {
  //   let name = candidateNames[i];
  //   Voting.deployed().then(function(contractInstance) {
  //     contractInstance.totalVotesFor.call(name).then(function(v) {
  //       $("#" + candidates[name]).html(v.toString());
  //     });
  //   })
  // }
});
