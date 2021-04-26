const YZT = artifacts.require("YZT")

module.exports = function(deployer) {
  // Use deployer to state migration tasks.

  deployer.deploy(YZT, 
    "YuenZe Token",
    "YZT",
    6, 
    10000000000,
    )
};
