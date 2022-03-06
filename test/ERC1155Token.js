const {expect} = require('chai');
const provider = waffle.provider;

describe("ERC1155 Token contract", ()=> {
	let Token, token, owner, addr1;

	let name = "testcoin";
	let symbol = "ttc";
	let uri = "http://testcoin/";

	before(async ()=> {
		Token = await ethers.getContractFactory("ERC1155Token");
	});

	beforeEach(async ()=> {
		token = await Token.deploy(name, symbol, uri);
    	[owner, addr1, addr2, _] = await ethers.getSigners();
	});

	describe("Deployment", ()=> {
		it("Should set token name, symbol and ui", async ()=> {
			expect(await token.name())
			.to 
			.equal(name);

			expect(await token.symbol())
			.to
			.equal(symbol);

			expect(await token.uri(0))
			.to
			.equal(uri + 0 + ".json");
		});
	});

	describe("functions tests", ()=> {
		it("Should allow to mint an specify amount of token", async()=> {
			await token.mint(owner.address, 1, 30);
			expect(await token.balanceOf(owner.address, 1))
			.to
			.equal(30);
		});

	})
});