import { expect } from "chai";
import { ethers } from "hardhat";
import { Overseer } from "../typechain-types";

describe("Overseer", function () {
  // We define a fixture to reuse the same setup in every test.

  let yourContract: Overseer;
  before(async () => {
    const [owner] = await ethers.getSigners();
    const yourContractFactory = await ethers.getContractFactory("Overseer");
    yourContract = (await yourContractFactory.deploy(owner.address)) as Overseer;
    await yourContract.deployed();
  });

  describe("Deployment", function () {
    it("Should have the right message on deploy", async function () {
      expect(await yourContract.greeting()).to.equal("Building Unstoppable Apps!!!");
    });

    it("Should allow setting a new message", async function () {
      const newGreeting = "Learn Scaffold-ETH 2! :)";

      await yourContract.setGreeting(newGreeting);
      expect(await yourContract.greeting()).to.equal(newGreeting);
    });
  });
});
