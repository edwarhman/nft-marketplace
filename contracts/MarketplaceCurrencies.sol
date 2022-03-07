pragma solidity >= 0.8.0 < 0.9.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MarketplaceCurrencies is Initializable, OwnableUpgradeable {
	address public daiAddress;
	address public linkAddress;

	function initialize(address _daiAddress, address _linkAddress) public initializer {
		__Ownable_init();
		daiAddress = _daiAddress;
		linkAddress = _linkAddress;
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
}