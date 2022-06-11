const { ethers } = require("hardhat");

describe("Voting", function () {
  it("test initial value", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();
    console.log('voting deployed at:'+ voting.address)
    expect((await voting.retrieve()).toNumber()).to.equal(0);
  });
   
});
