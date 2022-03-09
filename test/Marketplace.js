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
		// create a new offer variables
		let tokenId = 1;
		let tokenAmount = 20;
		let price = 100;

		it("set selling fee", async ()=> {
			await market.setFee(20);
			expect(await market.fee())
			.to
			.equal(20);
		})

		describe("create new offer assumtions", ()=> {

			it("Should allow to create a new offer", async ()=> {
				let expectedData = [
					token.address,
					ethers.BigNumber.from(tokenId),
					ethers.BigNumber.from(tokenAmount),
					ethers.BigNumber.from(price),
					owner.address
				]; 

				let tx = await token.mint(owner.address, tokenId, tokenAmount);
				//await tx.wait();

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

			it("Should not allow to create a new offer if the token address is not a ERC1155 token", async ()=> {
				await expect(market.createNewOffer(
					market.address,
					tokenId,
					tokenAmount + 20,
					week,
					price,
				))
				.to
				.be
				.reverted;
			});

			it("Should not allow to create a new offer if seller have not the specified amount of tokens", async ()=>{
				await expect(market.createNewOffer(
					token.address,
					tokenId,
					tokenAmount + 20,
					week,
					price,
				))
				.to
				.be
				.revertedWith("You do not have enough tokens to create the offer");
			});
		});

		describe("Cancel offer assumtions", ()=> {
			it("Should allow to cancel the offer", async ()=> {
				let expectedData = [
					ethers.constants.AddressZero,
					ethers.BigNumber.from(0),
					ethers.BigNumber.from(0),
					ethers.BigNumber.from(0),
					ethers.constants.AddressZero
				];

				await market.createNewOffer(
					token.address,
					tokenId,
					tokenAmount,
					week,
					price
				);

				await market.cancelOffer(0);

				let offerData = (await market.offers(0)).slice(0, expectedData.length);
				expect(offerData)
				.to
				.deep
				.equal(expectedData);
			});

			it("Should not allow to cancel the offer if tx sender is not the offer seller", async ()=> {
				await market.createNewOffer(
					token.address,
					tokenId,
					tokenAmount,
					week,
					price
				);

				await expect(market.connect(addr1).cancelOffer(0))
				.to
				.be
				.revertedWith("You are not the offer owner");
			});
		});

		describe("Accept offer assumtions", ()=> {
			beforeEach(async ()=> {
				await market.createNewOffer(
					token.address,
					tokenId,
					tokenAmount,
					week,
					price
				);
			})

			it("Should not allow to accept an offer if sent payment is less than offer price", async ()=> {
				await expect(market.connect(addr1).acceptOffer(0, "ETH"))
				.to
				.be
				.revertedWith("You have not send enough token for this transaction");
			});

			it("Should not allow to accept an offer if tx sender is offer seller", async ()=> {
				await expect(market.acceptOffer(0, "ETH", {value: price}))
				.to
				.be
				.revertedWith("You cannot buy your own tokens");
			})
		});
	});
});