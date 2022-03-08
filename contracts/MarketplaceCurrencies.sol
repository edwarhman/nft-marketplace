pragma solidity >= 0.8.0 < 0.9.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/Denominations.sol";

contract MarketplaceCurrencies is Initializable, OwnableUpgradeable {
	AggregatorV3Interface internal ethPriceFeed;
	AggregatorV3Interface internal daiPriceFeed;
	AggregatorV3Interface internal linkPriceFeed;

	enum Currency {
		ETH,
		DAI,
		LINK
	}

	function initialize(
		address _priceFeed,
		address _daiPriceFeed,
		address _linkPriceFeed
	)
	public
	initializer {
		__Ownable_init();
		ethPriceFeed = AggregatorV3Interface(_priceFeed);
		daiPriceFeed = AggregatorV3Interface(_daiPriceFeed);
		linkPriceFeed = AggregatorV3Interface(_linkPriceFeed);
	}

	function _getPrice(
		int offerPrice,
		Currency paymentMethod
	) 
	internal
	view
	returns(int) {
		int price;
		int currencyPrice;
		uint currencyDecimals;
		if(paymentMethod == Currency.ETH) {
			currencyPrice = _getEthUsdPrice();
			currencyDecimals = ethPriceFeed.decimals();
		} else if (paymentMethod == Currency.DAI) {
			currencyPrice = _getDaiUsdPrice();
			currencyDecimals = daiPriceFeed.decimals();
		} else if (paymentMethod == Currency.LINK) {
			currencyPrice = _getLinkUsdPrice();
			currencyDecimals = linkPriceFeed.decimals();
		}

		price =  1 ether * int(10**currencyDecimals) * offerPrice / currencyPrice; 
		return price;
	}

	function _getApprovedAmount(
		address buyer,
		uint sentValue,
		Currency paymentMethod
	) 
	internal
	view
	returns(uint) {
		return sentValue;
	}

	function _handlePayment(
		address buyer,
		uint price,
		uint approved,
		Currency paymentMethod
	)
	internal {

	}

	function _getEthUsdPrice() 
	public
	view
	returns(int) {
		(,int price,,,) = ethPriceFeed.latestRoundData();
		return price;
	}

	function _getDaiUsdPrice() 
	public
	view
	returns(int) {
		(,int price,,,) = daiPriceFeed.latestRoundData();
		return price;
	}

	function _getLinkUsdPrice() 
	public
	view
	returns(int) {
		(,int price,,,) = linkPriceFeed.latestRoundData();
		return price;
	}

	function getEthPriceFeed()
	public
	view
	returns(AggregatorV3Interface) {
		return ethPriceFeed;
	}

	function getDaiPriceFeed()
	public
	view
	returns(AggregatorV3Interface) {
		return daiPriceFeed;
	}

	function getLinkPriceFeed()
	public
	view
	returns(AggregatorV3Interface) {
		return linkPriceFeed;
	}
	
}