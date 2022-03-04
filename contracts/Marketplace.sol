pragma solidity >= 0.8.0 < 0.9.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Marketplace {
	struct Offer {
		address tokenAddress;
		uint tokenId;
		uint tokenAmount;
		uint deadline;
		uint price;
		address seller;
	}

	Offer[] offers;
	uint fee;

	//events

	event offerCreated(
		uint offerId,
		string tokenURI,
		uint tokenId,
		uint tokenAmount,
		uint deadline,
		uint price,
		address seller
	);

	event offerCancelled(
		uint offerId,
		uint tokenId,
		uint tokenAmount,
		uint price,
		address seller
	);

	event buyed (
		uint offerId,
		string tokenURI,
		uint tokenId,
		uint tokenAmount,
		uint price,
		address seller,
		address buyer
	);

	// Functions

	function setFee(uint _fee) public {
		fee = _fee;
	}

	function createNewOffer(
		address tokenAddress,
		uint tokenId,
		uint tokenAmount,
		uint deadline,
		uint price
	) 
	public {
		ERC1155 token = ERC1155(tokenAddress);
		require(
			token.balanceOf(msg.sender, tokenId) >= tokenAmount,
			"You do not have enough tokens to create the offer"
		);

		Offer memory offer = Offer(
			tokenAddress,
			tokenId,
			tokenAmount,
			deadline + block.timestamp,
			price,
			msg.sender
		);
		offers.push(offer);

		emit offerCreated(
			offers.length - 1,
			token.uri(tokenId),
		 	tokenId,
			tokenAmount,
			deadline,
			price,
			msg.sender
		);

	} 

	function cancelOffer(
		uint offerId
	)

	public {
		Offer storage offer = offers[offerId];
		uint tokenId = offer.tokenId;
		uint tokenAmount = offer.tokenAmount;
		uint price = offer.price;
		address seller = offer.seller;

		require(msg.sender == seller, "You are not the transfer owner");

		delete offers[offerId];

		emit offerCancelled(
			offerId,
			tokenId,
			tokenAmount,
			price,
			seller
		);
	}
}