pragma solidity >=0.8.0 < 0.9.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ERC1155Token is ERC1155 {
	string name;
	string symbol;

	constructor(
		string memory _name,
		string memory _symbol,
		string memory _uri
	) ERC1155(_uri) {
		name = _name;
		symbol = symbol;
	}

	function mint(address _to, uint _id, uint _amount) external {
    	_mint(_to, _id, _amount, "");
 	}
}