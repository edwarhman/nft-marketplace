const {expect} = require('chai');
const provider = waffle.provider;

describe("Marketplace Currencies management", ()=> {
	//contracts variables
	let Manager,
		manager,
		MockFeed,
		mockEthFeed,
		mockLinkFeed,
		mockDaiFeed,
		Coin,
		mockDaiCoin,
		mockLinkCoin,
		owner,
		addr1,
		addr2;

	//feeds variables
	let daiPrice = 100007329;
	let linkPrice = 1329348881;
	let ethPrice = 257543456568;
	let decimals = 8;

	Currency = {
		ETH: 0,
		DAI: 1,
		LINK: 2
	}

	before(async ()=> {
		Manager = await ethers.getContractFactory("TestMarketplaceCurrencies");
		MockFeed = await ethers.getContractFactory("MockV3Aggregator")
		Coin = await ethers.getContractFactory("ERC20Token");
	});

	beforeEach(async ()=> {
    	[owner, addr1, addr2, _] = await ethers.getSigners();
    	mockEthFeed = await MockFeed.deploy(decimals, ethPrice);
    	mockLinkFeed = await MockFeed.deploy(decimals, linkPrice);
    	mockDaiFeed = await MockFeed.deploy(decimals, daiPrice);
    	mockDaiCoin = await Coin.deploy("Mock DAI", "DAI");
    	mockLinkCoin = await Coin.deploy("Mock LINK", "LINK");
		manager = await upgrades.deployProxy(
			Manager, [
				mockEthFeed.address,
				mockDaiFeed.address,
				mockLinkFeed.address,
				mockDaiCoin.address,
				mockLinkCoin.address
			]);

		await manager.deployed();
	});

	describe("Deployment", ()=> {
		it("Should set ETH, DAI and LINK aggregators addresses correctly", async ()=> {
			const ethAddress = await manager.getEthPriceFeed();
			const daiAddress = await manager.getDaiPriceFeed();
			const linkAddress = await manager.getLinkPriceFeed();

			expect(ethAddress)
			.to
			.equal(mockEthFeed.address);

			expect(daiAddress)
			.to
			.equal(mockDaiFeed.address);

			expect(linkAddress)
			.to
			.equal(mockLinkFeed.address);
		});
	});

	describe("Correct connecting to chainlink oracle", ()=> {
		it("Should get prices from the mocks", async ()=> {
			expect(await manager.getEthUsdPrice())
			.to
			.equal((await mockEthFeed.latestRoundData()).answer);

			expect(await manager.getDaiUsdPrice())
			.to
			.equal((await mockDaiFeed.latestRoundData()).answer);

			expect(await manager.getLinkUsdPrice())
			.to
			.equal((await mockLinkFeed.latestRoundData()).answer);
						
		});
	});

	describe("Assumptions for functions used inside acceptOffer function", ()=> {
		it("getPrice should get the offer price in the different currencies correctly", async ()=> {
			let offerPrice = 75;
			let expectedEth = ethers
								.constants
								.WeiPerEther
								.mul(offerPrice)
								.mul(10**decimals)
								.div(ethPrice);
			let expectedDai = ethers
								.constants
								.WeiPerEther
								.mul(offerPrice)
								.mul(10**decimals)
								.div(daiPrice);
			let expectedLink = ethers
								.constants
								.WeiPerEther
								.mul(offerPrice)
								.mul(10**decimals)
								.div(linkPrice);

			expect((await manager.getPrice(offerPrice, Currency.ETH)))
			.to
			.equal(expectedEth);
			expect((await manager.getPrice(offerPrice, Currency.DAI)))
			.to
			.equal(expectedDai);
			expect((await manager.getPrice(offerPrice, Currency.LINK)))
			.to
			.equal(expectedLink);
		});

		it("getApprovedAmount should get the approved amounts per each coin", async ()=> {

			let approvedDai = ethers.constants.WeiPerEther.mul(100);
			let etherSent = "29121298983652304";
			await mockDaiCoin.approve(manager.address, approvedDai);

			expect(await manager.getApprovedAmount(owner.address, etherSent, Currency.ETH))
			.to
			.equal(etherSent);

			expect(await manager.getApprovedAmount(owner.address, 0, Currency.DAI))
			.to
			.equal(approvedDai);

			expect(await manager.getApprovedAmount(owner.address, 0, Currency.LINK))
			.to
			.equal(0);
		});

		describe("handlePayment function assertions", ()=> {
			let seller, buyer;
			let fee = 7;

			beforeEach(()=> {
				seller = addr1.address;
				buyer = owner.address;
			});

			it("Should send ETH payments correctly", async ()=> {
				let ethPrice = ethers.BigNumber.from("19121298983652304");
				let etherSent = ethers.BigNumber.from("29121298983652304");
				let previousEthBalance = await provider.getBalance(seller);

				await manager.handlePayment(
					seller,
					buyer,
					ethPrice,
					fee,
					etherSent,
					Currency.ETH,
					{value: etherSent}
				);

				console.log(previousEthBalance);
				console.log(await provider.getBalance(seller));

				expect(await provider.getBalance(seller))
				.to
				.equal(previousEthBalance.add(ethPrice).sub(ethPrice.mul(fee).div(100)));

				expect(await provider.getBalance(manager.address))
				.to
				.equal(ethPrice.mul(fee).div(100));
			});

			it("Should send DAI coins correctly", async ()=> {
				let daiPrice = ethers.BigNumber.from("4912129898365230400");

				await mockDaiCoin.approve(manager.address, daiPrice);
				await manager.handlePayment(
					seller,
					buyer,
					daiPrice,
					fee,
					daiPrice,
					Currency.DAI
				);

				expect(await mockDaiCoin.balanceOf(seller))
				.to
				.equal(daiPrice.sub(daiPrice.mul(fee).div(100)));
				expect(await mockDaiCoin.balanceOf(manager.address))
				.to
				.equal(daiPrice.mul(fee).div(100));
			});

			it("Should send LINK coins correctly", async ()=> {
				let linkPrice = ethers.BigNumber.from("4912129898365230400");

				await mockLinkCoin.approve(manager.address, linkPrice);
				await manager.handlePayment(
					seller,
					buyer,
					linkPrice,
					fee,
					linkPrice,
					Currency.LINK
				);

				expect(await mockLinkCoin.balanceOf(seller))
				.to
				.equal(linkPrice.sub(linkPrice.mul(fee).div(100)));
				expect(await mockLinkCoin.balanceOf(manager.address))
				.to
				.equal(linkPrice.mul(fee).div(100));
			});
		});
	});
});