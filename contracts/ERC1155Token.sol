pragma solidity >=0.8.0 < 0.9.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERC1155Token is ERC1155 {
	string public name;
	string public symbol;
	string baseExtension = ".json";

	constructor(
		string memory _name,
		string memory _symbol,
		string memory _uri
	) ERC1155(_uri) {
		name = _name;
		symbol = _symbol;
	}

	function mint(address _to, uint _id, uint _amount) external {
    	_mint(_to, _id, _amount, "");
 	}

 	function uri(uint tokenId) public view override returns(string memory) {
 		return bytes(super.uri(tokenId)).length > 0
        ? string(abi.encodePacked(super.uri(tokenId), Strings.toString(tokenId), baseExtension))
        : "";
 	}
}