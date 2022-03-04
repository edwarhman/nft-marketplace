pragma solidity >= 0.8.0 < 0.9.0;

contract Marketplace {
	struct offer {
		address tokenAddress;
		uint tokenId;
		uint tokenAmount;
		uint deadline;
		uint price;
	}

	offer[] offers;
	uint fee;

	function setFee(uint _fee) public {
		fee = _fee;
	}
}