const YZT = artifacts.require("YZT");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("YZT", function (accounts) {

  let yztContract;

  before("Deploy YZT contract", async () => {
    console.log("deploying YZT contract...")
    yztContract = await YZT.deployed()

    assert.equal(await yztContract.owner(), accounts[0], "wrong contract owner");
    assert.equal(await yztContract.name(), "YuenZe Token", "wrong contract name");
    assert.equal(await yztContract.symbol(), "YZT", "wrong contract symbol");
  })

  it("should have correct contract name", async function () {
    return await yztContract.name(), "YuenZe Token", "wrong contract name";
  });
});
