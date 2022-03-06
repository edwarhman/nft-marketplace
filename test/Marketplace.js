const {expect} = require('chai');
const provider = waffle.provider;

describe("ERC1155 Token contract", ()=> {
	let Market, market, owner, addr1, addr2;

	let name = "testcoin";
	let symbol = "ttc";
	let uri = "http://testcoin/";

	before(async ()=> {
		Market = await ethers.getContractFactory("Marketplace");
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
	});


});