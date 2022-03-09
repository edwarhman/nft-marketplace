const {expect} = require('chai');
const provider = waffle.provider;

describe("Marketplace contract", ()=> {
	//smart contracts variables
	let Market,
		market,
		Token,
		token,
		owner,
		addr1,
		addr2,
		MockFeed,
		mockEthFeed,
		mockLinkFeed,
		mockDaiFeed,
		MockCoin,
		mockDaiCoin,
		mockLinkCoin;

	//test token initialize variables
	let tokenName = "testcoin";
	let tokenSymbol = "ttc";
	let tokenUri = "http://testcoin/";

	//market variables
	let week = 10;

	//feeds variables
	let daiPrice = 100007329;
	let linkPrice = 1329348881;
	let ethPrice = 257543456568;
	let decimals = 8;

	before(async ()=> {
		Market = await ethers.getContractFactory("Marketplace");
		Token = await ethers.getContractFactory("ERC1155Token");
		token = await Token.deploy(tokenName, tokenSymbol, tokenUri);
		MockFeed = await ethers.getContractFactory("MockV3Aggregator")
		MockCoin = await ethers.getContractFactory("ERC20Token");
	});

	beforeEach(async ()=> {
		mockEthFeed = await MockFeed.deploy(decimals, ethPrice);
    	mockLinkFeed = await MockFeed.deploy(decimals, linkPrice);
    	mockDaiFeed = await MockFeed.deploy(decimals, daiPrice);
    	mockDaiCoin = await MockCoin.deploy("Mock DAI", "DAI");
    	mockLinkCoin = await MockCoin.deploy("Mock LINK", "LINK");
		market = await upgrades.deployProxy(
			Market, [
				mockEthFeed.address,
				mockDaiFeed.address,
				mockLinkFeed.address,
				mockDaiCoin.address,
				mockLinkCoin.address
		]);
    	[owner, addr1, addr2, _] = await ethers.getSigners();
	});

	describe("Public functions tests", ()=> {
		// create a new offer variables
		let tokenId = 1;
		let tokenAmount = 20;
		let price = 100;

		let emptyOffer = [
					ethers.constants.AddressZero,
					ethers.BigNumber.from(0),
					ethers.BigNumber.from(0),
					ethers.BigNumber.from(0),
					ethers.constants.AddressZero
				];

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
			beforeEach(async ()=> {
				await market.createNewOffer(
					token.address,
					tokenId,
					tokenAmount,
					week,
					price
				);
			});

			it("Should allow to cancel the offer", async ()=> {
				


				await market.cancelOffer(0);

				let offerData = (await market.offers(0)).slice(0, emptyOffer.length);
				expect(offerData)
				.to
				.deep
				.equal(emptyOffer);
			});

			it("Should not allow to cancel the offer if tx sender is not the offer seller", async ()=> {
				await expect(market.connect(addr1).cancelOffer(0))
				.to
				.be
				.revertedWith("You are not the offer owner");
			});
		});

		describe("Accept offer assumtions", ()=> {
			const ethEnum = 0;
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
				await expect(market.connect(addr1).acceptOffer(0, ethEnum))
				.to
				.be
				.revertedWith("You have not sent enough token for this transaction");
			});

			it("Should not allow to accept an offer if tx sender is offer seller", async ()=> {
				await expect(market.acceptOffer(0, ethEnum, {value: price}))
				.to
				.be
				.revertedWith("You cannot buy your own tokens");
			});

			it("Should allow to accept the offer when sender is not the seller and sent enough money", async ()=> {
				await market.connect(addr1).acceptOffer(0, ethEnum, {value: price});


			})
		});
	});
});