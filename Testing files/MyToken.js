const {expect} = require("chai");
const {ethers} = require("hardhat");
const hrd = require("hardhat");


const convertToWei = (eths) => ethers.utils.parseEther(eths.toString());//ether in string to wei
const convertFromWei = (inWei) => ethers.utils.formatEther(inWei);//

describe("Tax Token contract: ", () => {
    let token, deployer, addr1, addr2;
    const maxSupply = convertToWei(2000000000);

    beforeEach(async () => {
        [deployer, addr1, addr2] = await hrd.ethers.getSigners();

        const Token = await hrd.ethers.getContractFactory("MyToken");
        token = await Token.deploy(maxSupply);
        await token.deployed();
    });

    describe("should assign basic properties", () => {
        it("Should assign a token name", async () => { 
            const name = await token.name();
            expect(name).to.equal("My Tax Token");
        });

        it("Should assign a Symbol name", async () => {
            const symbol = await token.symbol();
            expect(symbol).to.equal("MTT");
        });
    });
    
    describe("Minting token", () => {
        
        let investAmount = convertToWei(1);
        let mintedAmount = convertToWei(10000000);
        
        it("Should mint token for 1 Ether", async () => {
            await token.connect(addr1).mint({value: investAmount});
            const balanceOfAccount = await token.balanceOf(addr1.address);
            expect(balanceOfAccount).to.equal(mintedAmount);
        });

        it("Should revert with error if the invested amount is <0.1 ether and >2 ether", async () => {
            investAmount = convertToWei(0.01);
            expect(token.connect(addr1).mint({value: investAmount})).to.be.revertedWith("Investment amount is low");
            investAmount = convertToWei(2);
            expect(token.connect(addr1).mint({value: investAmount})).to.be.revertedWith("Investement amount is too high");
        });

        it("Should revert with error if the the maximum mint limit has reached", async () => {
            investAmount = convertToWei(2.1);
            expect(token.connect(addr1).mint({value: investAmount}))
                .to.be.revertedWith("Max limit reached");
        });
    });

    describe("Transfer Token ", () => {
        let taxPercentage, transferAmount, taxableAmount, tx;
        let investAmount = convertToWei(1);
        
        beforeEach(async() => {
            transferAmount = convertToWei(1000)
            taxPercentage = await token.getTaxPercentage();
            taxableAmount = transferAmount / taxPercentage;
            await token.connect(addr1).mint({value: investAmount});
        });

        it("Should charge decided percentage of fees on not Exempted Accounts", async () => {
            tx = await token.connect(addr1).transfer(addr2.address, transferAmount);
            const balanceOfToAccount = await token.balanceOf(addr2.address);
            transferAmount -= taxableAmount;
            expect(balanceOfToAccount).to.equal(BigInt(transferAmount));
        });

        it("Should burn the taxFess", async () => {
            const receipt = await tx.wait();
            const events = receipt.events;
            expect(events.length).to.eq(2);
            expect(events[1].event).to.equal("Transfer");
            expect(events[1].args.to).to.equal(ethers.constants.AddressZero);
            expect(events[1].args.value).to.equal(BigInt(taxableAmount));
        });

        it("Should not charge decided percenta of fees on Exempted Accounts", async () => {
            await token.setExemptedAccount(addr1.address);
            await token.connect(addr1).transfer(addr2.address, transferAmount);
            const balanceOfToAccount = await token.balanceOf(addr2.address);  
            expect(balanceOfToAccount).to.equal(BigInt(transferAmount));
        });
    });

    describe("Burn tokens", () => {
        let tx, receipt, events;
        const investAmount = convertToWei(1);

        beforeEach(async () => {
            await token.connect(addr1).mint({value: investAmount});
        });

        it("Should Emit a transfer Event while burning the tokens", async () => {
            tx = await token.connect(addr1).burn(convertToWei(0.1));
            receipt = await tx.wait();
            events = receipt.events;
            expect(events.length).equal(1);
            expect(events[0].event).to.equal("Transfer");
            expect(events[0].args.to).to.equal(ethers.constants.AddressZero);
        });

        it("Should Transfer the ether according to the amount of token burned", async ()=> {
            const balanceBefore = (await ethers.provider.getBalance(addr1.address));
            tx = await token.connect(addr1).burn(convertToWei(10000000));
            let balanceAfter = (await ethers.provider.getBalance(addr1.address));
            balanceAfter =  (parseInt(convertFromWei(balanceAfter))) - (parseInt(convertFromWei(balanceBefore)))
            expect(balanceAfter).to.equal(1);
        });
    });
});
