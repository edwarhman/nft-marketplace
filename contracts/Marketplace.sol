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

	//events

	event newOffer(
		uint offerId,
		string tokenURI,
		uint tokenId,
		uint tokenAmount,
		uint deadline,
		uint price,
		address seller
	);

	event canceledOffer(
		uint offerId,
		string tokenURI,
		uint tokenId,
		uint tokenAmount,
		uint price,
		address seller
	)

	event buyed (
		uint offerId,
		string tokenURI,
		uint tokenId,
		uint tokenAmount,
		uint price,
		address seller,
		address buyer
	)
	
	function setFee(uint _fee) public {
		fee = _fee;
	}

}