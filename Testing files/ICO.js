const {expect} = require("chai");
const hrd = require("hardhat");
const {ethers} = require("hardhat");

const convertToWei = (eths) => hrd.ethers.utils.parseEther(eths.toString());
const convertFromWei = (inWei) => hrd.ethers.utils.formatEther(inWei);

describe("ICO contract", ()=> {
    let ico, token, deployer, add1;
    const amount = convertToWei(500);
    const totalMintAmount = convertToWei(10000000);

    beforeEach(async () => {
        [deployer, add1] = await ethers.getSigners();

        const Token = await ethers.getContractFactory("Token");
        token = await Token.deploy();
        await token.deployed();

        const ICO = await ethers.getContractFactory("ICO");
        ico = await ICO.deploy(token.address, deployer.address, 1, 2, convertToWei(0.01));
        await ico.deployed();

        await token.approve(ico.address, convertToWei(50000));
    });

    describe("should be deployed successfully: ", () => {
        it("token should be deployed properly and should have name", async () => {
            const name = await token.name();
            expect(name).to.equal("Standard Token");
        });
    });

    describe("contract is deployed successfully: ", () => {
        it("Deployed ICO contract should have a valid address", async () => {
            expect(ico.address).not.equal("0x0");
        }); 

        it("Deployed ICO contract shold have valid parameters", async () => {
            const provider = await ico.getProviders();
            expect(provider.token).to.equal(token.address);
            expect(provider.owner).to.equal(deployer.address);
            expect(provider.startTime.toString()).to.equal("1");
            expect(provider.endTime.toString()).to.equal("2");
            expect(provider.pricePerToken).to.equal(convertToWei(0.01));
        });
    });

    describe("addToken function should works as expected: ", () => {
        it("caller of the function and the owner of the token should be same", async () => {
            const provider = await ico.getProviders();
            expect(provider.owner).to.equal(deployer.address);
        });

        it("Check if the contract has allowance to spend the tokens", async () => {
            const allowance = await token.allowance(deployer.address, ico.address);
            expect(allowance).to.equal(convertToWei(50000));
        });

        it("Try adding some tokens to the contract using the addToken function", async ()=> {
            await ico.addToken(amount);
            const addressBalance = await token.balanceOf(ico.address);
            expect(addressBalance).to.equal(convertToWei(500));
        });
    });

    describe("Test to check if the invest function works as expected: ", () => {
        beforeEach(async () => {
            await ico.addToken(amount);
        });
        
        it("Invest small amount of ether to check the invest", async () => {
            await token.balanceOf(ico.address); 
            await ico.connect(add1).invest({value: convertToWei(0.1)});
            expect(await token.balanceOf(ico.address)).to.equal(convertToWei(490));
        });

        it("Invest large amount to test revert feature", async () => {
            const initialBalance = parseInt(convertFromWei(await ethers.provider.getBalance(add1.address)));
            const tx = await ico.connect(add1).invest({value: convertToWei(6)});
            const finalBalance = parseInt(convertFromWei(await ethers.provider.getBalance(add1.address)));
            expect(await token.balanceOf(ico.address)).to.equal(0);
            expect(initialBalance - finalBalance).to.equal(5);
            expect(await token.balanceOf(add1.address)).to.equal(amount);
        });
    });

    describe("Test to check if the withdrawFunds function works as expected: ", () => {
        beforeEach(async () => {
            await ico.addToken(amount);
        });

        it("Call the withdrawFunds function and check if the token balance of the contract is transferred to the owner", async () => {
            let currentBalanceOfICO = await token.balanceOf(ico.address);
            expect(currentBalanceOfICO).to.equal(amount);
            const provider = await ico.getProviders();
            expect(provider.owner).to.equal(deployer.address);
            await ico.withdrawFunds();
            currentBalanceOfICO = await token.balanceOf(ico.address);
            expect(currentBalanceOfICO).to.equal(0);
            expect(await token.balanceOf(deployer.address)).to.equal(totalMintAmount);
        });
        
        it("should revert if the caller is not the owner of the ICO", async () => {
            expect(ico.connect(add1).withdrawFunds()).to.be.revertedWith("Not Owner");
        });

        it("Should Revert if the funds are 0", async () => {
            const tx = await ico.connect(add1).invest({value: convertToWei(6)});
            expect(ico.withdrawFunds()).to.be.revertedWith("Insufficient Funds");
        });
    });
});
