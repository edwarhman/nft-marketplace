pragma solidity >= 0.7.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Token is ERC20, Ownable {
	constructor(string memory name, string memory symbol) ERC20 (name, symbol) {
		_mint(msg.sender, 10000000 * 10**18);
	}
}