pragma solidity >= 0.8.0 < 0.9.0;
import "../MarketplaceCurrencies.sol";
import "hardhat/console.sol";

contract TestMarketplaceCurrencies is MarketplaceCurrencies {
	function getPrice(
		int offerPrice,
		Currency paymentMethod
	) 
	external
	view
	returns(int) {		
		int result;
		result = _getPrice(offerPrice, paymentMethod);
		console.log("The price in the Currency is: %d", uint(result));
		return result;
	}

	function getApprovedAmount(
		address buyer,
		uint sentValue,
		Currency paymentMethod
	) 
	external
	view
	returns(uint) {
		return _getApprovedAmount(buyer, sentValue, paymentMethod);
	}

	function handlePayment(
		address buyer,
		uint price,
		uint approved,
		Currency paymentMethod
	)
	external {
		_handlePayment(buyer, price, approved, paymentMethod);
	}

	function getEthUsdPrice() 
	external
	view
	returns(int) {
		return _getEthUsdPrice();
	}

	function getDaiUsdPrice() 
	external
	view
	returns(int) {
		return _getDaiUsdPrice();
	}

	function getLinkUsdPrice() 
	external
	view
	returns(int) {
		return _getLinkUsdPrice();
	}
}