//using mocha framework and chai library
const {expect} = require("chai");
const {ethers} = require("hardhat");
const hrd = require("hardhat");

const convertToWei = (inEther) => ethers.utils.parseEther(inEther.toString());
    

describe("Standard Token Contract", () => {
    let token, deployer;
    const mintedAmount = convertToWei(10000000);
    beforeEach(async () => {
        const Token = await hrd.ethers.getContractFactory("Token");
        [deployer] = await hrd.ethers.getSigners();
        token = await Token.deploy();
        await token.deployed();
    });

    describe("Testing variable assignments", () => {
        it("Should assign a token name", async function() { 
            const name = await token.name();
            expect(name).to.equal("Standard Token");
        });

        it("Should assign a Token Symbol", async () => {
            const symbol = await token.symbol();
            expect(symbol).to.equal("STT");
        });
    });

    describe("Tokens Minting", ()=> {
        it("Verify that tokens are minted correctly", async function() {
            expect(await token.balanceOf(deployer.address)).to.equal(mintedAmount);
        });
    });
});
