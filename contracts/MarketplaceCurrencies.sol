pragma solidity >= 0.8.0 < 0.9.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/Denominations.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


///@title Marketplace Currencies 
///@author Emerson Warhman
///@notice This contract is used to get currencies prices from oracles and manage payments that use it 
contract MarketplaceCurrencies is Initializable, AccessControlUpgradeable {
	AggregatorV3Interface internal ethPriceFeed;
	AggregatorV3Interface internal daiPriceFeed;
	AggregatorV3Interface internal linkPriceFeed;

	enum Currency {
		ETH,
		DAI,
		LINK
	}

	mapping(Currency => address) currencyToAddress;

	function __MarketplaceCurrencies_init(
		address _priceFeed,
		address _daiPriceFeed,
		address _linkPriceFeed,
		address _daiContract,
		address _linkContract
	)
	internal
	onlyInitializing {
		ethPriceFeed = AggregatorV3Interface(_priceFeed);
		daiPriceFeed = AggregatorV3Interface(_daiPriceFeed);
		linkPriceFeed = AggregatorV3Interface(_linkPriceFeed);
		currencyToAddress[Currency.DAI] = _daiContract;
		currencyToAddress[Currency.LINK] = _linkContract;
	}

	///@dev Get the offer price in the specified token
	function _getPrice(
		uint offerPrice,
		Currency paymentMethod
	) 
	internal
	view
	returns(uint) {
		uint price;
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
		///@dev All currencies used have 18 decimals so we use 1 ether unit
		price =  1 ether * (10**currencyDecimals) * offerPrice / uint(currencyPrice); 
		return price;
	}

	///@dev Get total approved amount by the seller to do the transaction
	///@dev 
	function _getApprovedAmount(
		address buyer,
		uint sentValue,
		Currency paymentMethod
	) 
	internal
	view
	returns(uint) {
		uint approvedAmount;

		if(paymentMethod == Currency.ETH) {
			approvedAmount = sentValue;
		} else if (paymentMethod == Currency.DAI) {
			approvedAmount = ERC20(currencyToAddress[Currency.DAI]).allowance(buyer, address(this));
		} else if (paymentMethod == Currency.LINK) {
			approvedAmount = ERC20(currencyToAddress[Currency.LINK]).allowance(buyer, address(this));
		}
		return approvedAmount;
	}

	///@dev handle the offer payment
	///@dev discount fee from the payment and send the rest to the seller
	///@dev if seller sent to much ETH the contract return him the exceeds of funds 
	function _handlePayment(
		address seller,
		address buyer,
		uint price,
		uint fee,
		uint approvedAmount,
		Currency paymentMethod
	)
	internal {
		uint toDiscount = price * fee / 100;
		ERC20 coin;

		if(paymentMethod == Currency.ETH) {
			(bool fe,) = payable(seller).call{value: price - toDiscount}("");
			require(fe, "ETH was not sent to offer seller");
			
			if (approvedAmount > price) {
				(bool re,) = payable(buyer).call{value:approvedAmount - price}("");
				require(re, "Exceeds of ETH was not returned");
			}
		} else if (paymentMethod == Currency.DAI) {
			coin = ERC20(currencyToAddress[Currency.DAI]);

			coin.transferFrom(
				buyer,
				address(this),
				toDiscount
			);
			coin.transferFrom(
				buyer,
				seller,
				price - toDiscount
			);
		} else if (paymentMethod == Currency.LINK) {
			coin = ERC20(currencyToAddress[Currency.LINK]);

			coin.transferFrom(
				buyer,
				address(this),
				toDiscount
			);
			coin.transferFrom(
				buyer,
				seller,
				price - toDiscount
			);
		}
	}

	///@dev get current ETH price in USD from the oracle
	function _getEthUsdPrice() 
	internal
	view
	returns(int) {
		(,int price,,,) = ethPriceFeed.latestRoundData();
		return price;
	}

	///@dev get current DAI price in USD from the oracle
	function _getDaiUsdPrice() 
	internal
	view
	returns(int) {
		(,int price,,,) = daiPriceFeed.latestRoundData();
		return price;
	}

	///@dev get current LINK price in USD from the oracle
	function _getLinkUsdPrice() 
	internal
	view
	returns(int) {
		(,int price,,,) = linkPriceFeed.latestRoundData();
		return price;
	}

	///@notice Get the ETH price feed
	///@return Price feed address
	function getEthPriceFeed()
	public
	view
	returns(AggregatorV3Interface) {
		return ethPriceFeed;
	}


	///@notice Get the DAI price feed
	///@return Price feed address
	function getDaiPriceFeed()
	public
	view
	returns(AggregatorV3Interface) {
		return daiPriceFeed;
	}


	///@notice Get the LINK price feed
	///@return Price feed address
	function getLinkPriceFeed()
	public
	view
	returns(AggregatorV3Interface) {
		return linkPriceFeed;
	}
	
}