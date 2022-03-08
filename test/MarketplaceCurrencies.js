const {expect} = require('chai');
const provider = waffle.provider;

describe("Marketplace Currencies management", ()=> {
	let Manager, manager, Mock, mockEth, mockLink, mockDai, owner, addr1, addr2;
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
		Mock = await ethers.getContractFactory("MockV3Aggregator")
		Manager = await ethers.getContractFactory("TestMarketplaceCurrencies");
	});

	beforeEach(async ()=> {
    	[owner, addr1, addr2, _] = await ethers.getSigners();
    	mockEth = await Mock.deploy(decimals, ethPrice);
    	mockLink = await Mock.deploy(decimals, linkPrice);
    	mockDai = await Mock.deploy(decimals, daiPrice);
		manager = await upgrades.deployProxy(Manager, [mockEth.address, mockDai.address, mockLink.address]);
		await manager.deployed();
	});

	describe("Deployment", ()=> {
		it("Should set ETH, DAI and LINK aggregators addresses correctly", async ()=> {
			const ethAddress = await manager.getEthPriceFeed();
			const daiAddress = await manager.getDaiPriceFeed();
			const linkAddress = await manager.getLinkPriceFeed();

			expect(ethAddress)
			.to
			.equal(mockEth.address);

			expect(daiAddress)
			.to
			.equal(mockDai.address);

			expect(linkAddress)
			.to
			.equal(mockLink.address);
		});
	});

	describe("Correct connecting to chainlink oracle", ()=> {
		it("Should get prices from the mocks", async ()=> {
			expect(await manager.getEthUsdPrice())
			.to
			.equal((await mockEth.latestRoundData()).answer);

			expect(await manager.getDaiUsdPrice())
			.to
			.equal((await mockDai.latestRoundData()).answer);

			expect(await manager.getLinkUsdPrice())
			.to
			.equal((await mockLink.latestRoundData()).answer);
						
		});
	});

	describe("Assumptions for functions used inside acceptOffer function", ()=> {
		it("getPrice should get the offer price in the different currencies correctly", async ()=> {
			let offerPrice = 99;
			let expectedEth = ethers.constants.WeiPerEther.mul(offerPrice).mul(10**decimals).div(ethPrice);
			let expectedDai = ethers.constants.WeiPerEther.mul(offerPrice).mul(10**decimals).div(daiPrice);
			let expectedLink = ethers.constants.WeiPerEther.mul(offerPrice).mul(10**decimals).div(linkPrice);

			expect((await manager.getPrice(offerPrice, Currency.ETH)))
			.to
			.equal(expectedEth);
			expect((await manager.getPrice(offerPrice, Currency.DAI)))
			.to
			.equal(expectedDai);
			expect((await manager.getPrice(offerPrice, Currency.LINK)))
			.to
			.equal(expectedLink);
		})
	});
});