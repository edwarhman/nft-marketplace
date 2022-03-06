const {expect} = require('chai');
const provider = waffle.provider;

describe("Marketplace contract", ()=> {
	let Market, market, Token, token, owner, addr1, addr2;

	//test token initialize variables
	let tokenName = "testcoin";
	let tokenSymbol = "ttc";
	let tokenUri = "http://testcoin/";

	//market variables
	let week = 10;

	before(async ()=> {
		Market = await ethers.getContractFactory("Marketplace");
		Token = await ethers.getContractFactory("ERC1155Token");
		token = await Token.deploy(tokenName, tokenSymbol, tokenUri);
	});

	beforeEach(async ()=> {
		market = await Market.deploy();
    	[owner, addr1, addr2, _] = await ethers.getSigners();
	});

	describe("Public functions tests", ()=> {
		it("set selling fee", async ()=> {
			await market.setFee(20);
			expect(await market.fee())
			.to
			.equal(20);
		})

		describe("create new offer assumtions", ()=> {
			let tokenId = 1;
			let tokenAmount = 20;
			let price = 100;

			it("Should allow to create a new offer", async ()=> {
				let expectedData = [
					token.address,
					ethers.BigNumber.from(tokenId),
					ethers.BigNumber.from(tokenAmount),
					ethers.BigNumber.from(price),
					owner.address
				]; 

				let tx = await token.mint(owner.address, tokenId, tokenAmount);
				await tx.wait();

				await market.createNewOffer(
					token.address,
					tokenId,
					tokenAmount,
					week,
					price
				);

				let offerData = (await market.offers(0)).slice(0, expectedData.length);
				expect(offerData)
				.to
				.deep
				.equal(expectedData);
			});
		});
	});


});