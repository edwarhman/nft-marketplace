const {expect} = require('chai');
const provider = waffle.provider;

describe("Marketplace Currencies management", ()=> {
	let Manager, manager, owner, addr1, addr2;

	let name = "testcoin";
	let symbol = "ttc";
	let uri = "http://testcoin/";

	before(async ()=> {
		Manager = await ethers.getContractFactory("MarketplaceCurrencies");
	});

	beforeEach(async ()=> {
    	[owner, addr1, addr2, _] = await ethers.getSigners();
		manager = await upgrades.deployProxy(Manager, [owner.address, addr1.address]);
	});

	describe("Deployment", ()=> {
		it("Should set dai and link contracts addresses", async ()=> {
			expect(await manager.daiAddress())
			.to 
			.equal(owner.address);

			expect(await manager.linkAddress())
			.to
			.equal(addr1.address);
		});
	});
});