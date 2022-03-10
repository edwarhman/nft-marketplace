pragma solidity >= 0.8.0 < 0.9.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./MarketplaceCurrencies.sol";


contract Marketplace is MarketplaceCurrencies {
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
	address recipient;
	///@notice Role required to manipulate admin functions
	bytes32 public constant ADMIN = keccak256("ADMIN");

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
	function initialize(
		address _ethPriceFeed,
		address _daiPriceFeed,
		address _linkPriceFeed,
		address _daiContract,
		address _linkContract,
		uint _fee
	)
	public
	initializer {
		__MarketplaceCurrencies_init(
			_ethPriceFeed,
			_daiPriceFeed,
			_linkPriceFeed,
			_daiContract,
			_linkContract
		);
		_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
		_setupRole(ADMIN, msg.sender);
		setFee(_fee);
		setRecipient(msg.sender);
	}

	function setFee(uint _fee) public onlyRole(ADMIN) {
		fee = _fee;
	}

	function setRecipient(address _recipient) public onlyRole(ADMIN) {
		recipient = _recipient;
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

	function acceptOffer(
		uint offerId,
		Currency paymentMethod
	)
	payable 
	public {
		Offer memory offer = offers[offerId];
		uint price = _getPrice(offer.price, paymentMethod);
		uint approvedAmount = _getApprovedAmount(msg.sender, msg.value, paymentMethod);

		require(offer.seller != address(0), "Specified Offer does not exist");
		require(offer.deadline > block.timestamp, "The offer has expired");
		require(offer.seller != msg.sender, "You cannot buy your own tokens");
		require(approvedAmount >= price, "You have not sent enough token for this transaction");
		
		_handlePayment(
			offer.seller,
			msg.sender,
			price,
			fee,
			approvedAmount,
			paymentMethod
		);

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

	///@notice let the contract recipient to withdraw the funds
	function withdraw() public payable onlyRole(ADMIN) {
		ERC20 daiCoin = ERC20(currencyToAddress[Currency.DAI]);
		ERC20 linkCoin = ERC20(currencyToAddress[Currency.LINK]);

		(bool os,) = payable(recipient).call{value : address(this).balance}("");
		require(os, "ETH cannot be sent to recipient");

		daiCoin.transfer(recipient, daiCoin.balanceOf(address(this)));
		linkCoin.transfer(recipient, linkCoin.balanceOf(address(this)));
	}
}