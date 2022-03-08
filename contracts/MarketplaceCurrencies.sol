pragma solidity >= 0.8.0 < 0.9.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/Denominations.sol";

contract MarketplaceCurrencies is Initializable, OwnableUpgradeable {
	AggregatorV3Interface internal ethPriceFeed;
	AggregatorV3Interface internal daiPriceFeed;
	AggregatorV3Interface internal linkPriceFeed;

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
		uint offerPrice,
		string memory paymentMethod
	) 
	internal
	returns(uint) {
		return offerPrice;
	}

	function _getApprovedAmount(
		address buyer,
		uint sentValue,
		string memory paymentMethod
	) 
	internal
	returns(uint) {
		return sentValue;
	}

	function _handlePayment(
		address buyer,
		uint price,
		uint approved,
		string memory paymentMethod
	)
	internal {

	}

	function getEthUsdPrice() 
	public
	view
	returns(int) {
		(,int price,,,) = ethPriceFeed.latestRoundData();
		return price;
	}

	function getDaiUsdPrice() 
	public
	view
	returns(int) {
		(,int price,,,) = daiPriceFeed.latestRoundData();
		return price;
	}

	function getLinkUsdPrice() 
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