pragma solidity >= 0.8.0 < 0.9.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Marketplace {
	struct Offer {
		address tokenAddress;
		uint tokenId;
		uint tokenAmount;
		uint price;
		address seller;
		uint deadline;
	}

	Offer[] public offers;
	uint public fee;

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
		require(ERC1155(tokenAddress).supportsInterface(0x0e89341c), "The specified token address is not a ERC1155 token");
		ERC1155 token = ERC1155(tokenAddress);
		require(
			token.balanceOf(msg.sender, tokenId) >= tokenAmount,
			"You do not have enough tokens to create the offer"
		);

		Offer memory offer = Offer(
			tokenAddress,
			tokenId,
			tokenAmount,
			price,
			msg.sender,
			deadline + block.timestamp
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

		require(msg.sender == seller, "You are not the offer owner");

		delete offers[offerId];

		emit offerCancelled(
			offerId,
			tokenId,
			tokenAmount,
			price,
			seller
		);
	}

	function buyTokens(
		uint offerId,
		string memory paymentMethod
	)
	payable 
	public {
		Offer memory offer = offers[offerId];
		uint price = _getPrice(offer.price, paymentMethod);
		uint approvedAmount = _getApprovedAmount(msg.sender, msg.value, paymentMethod);

		require(approvedAmount >= price, "You have not send enough token for this transaction");
		require(offer.seller != msg.sender, "You cannot buy your own tokens");
		_handlePayment(msg.sender, price, approvedAmount, paymentMethod);

		delete offers[offerId];

		emit buyed (
			offerId,
			offer.tokenId,
			offer.tokenAmount,
			offer.price,
			offer.seller,
			msg.sender
		);
	}

	function _getPrice(
		uint offerPrice,
		string memory paymentMethod
	) 
	internal
	returns(uint) {
		return 1;
	}

	function _getApprovedAmount(
		address buyer,
		uint sentValue,
		string memory paymentMethod
	) 
	internal
	returns(uint) {
		return 1;
	}

	function _handlePayment(
		address buyer,
		uint price,
		uint approved,
		string memory paymentMethod
	)
	internal {

	}

}