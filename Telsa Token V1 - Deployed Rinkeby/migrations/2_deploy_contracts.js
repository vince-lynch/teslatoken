var Contract = artifacts.require("./FixedSupplyToken.sol");
module.exports = function(deployer) {
  deployer.deploy(Contract);
};
