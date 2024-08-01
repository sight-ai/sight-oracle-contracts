import { loadFixture, time } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { getAddress } from "viem";

describe("Oracle", function () {
  async function deployOracleFixture() {
    const [owner, otherAccount] = await hre.viem.getWalletClients();
    const publicClient = await hre.viem.getPublicClient();

    const oracle = await hre.viem.deployContract("Oracle", [], {});

    return {
      oracle,
      owner,
      otherAccount,
      publicClient,
    };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { oracle, owner } = await loadFixture(deployOracleFixture);

      expect(await oracle.read.owner()).to.equal(getAddress(owner.account.address));
    });
  });
});
