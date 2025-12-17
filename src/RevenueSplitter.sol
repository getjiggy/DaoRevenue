pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT
import {IRevenueSplitter} from "./interfaces/IRevenueSplitter.sol";
import {IDividendDistributor} from "./interfaces/IDividendDistributor.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RevenueSplitter {
    using SafeERC20 for IERC20;
    IDividendDistributor private _dividendDistributor;

    address private _treasury;
    uint16 private _dividendSplitPercentage;

    uint16 private constant DIVISOR = 10000;

    error EthTransferFailed();

    constructor(uint16 dividendSplitPercentage_, address dividendDistributor_, address treasury_) {
        require(dividendSplitPercentage_ <= DIVISOR, "RevenueSplitter: Dividend split percentage must be <= 100%");
        _dividendSplitPercentage = dividendSplitPercentage_;
        _dividendDistributor = IDividendDistributor(dividendDistributor_);
        _treasury = treasury_;
    }

    function _splitTokenRevenue(IERC20 token) internal {
        uint256 balance = token.balanceOf(address(this));
        uint256 dividendAmount = (balance * _dividendSplitPercentage) / DIVISOR;
        uint256 treasuryAmount = balance - dividendAmount;

        // Distribute dividends
        if (dividendAmount > 0) {
            token.approve(address(_dividendDistributor), dividendAmount);
            _dividendDistributor.distribute(address(token), dividendAmount);
        }

        // Transfer to treasury
        if (treasuryAmount > 0) {
            token.safeTransfer(_treasury, treasuryAmount);
        }
    }

    function _splitEthRevenue() internal {
        uint256 value = address(this).balance;
        uint256 dividendAmount = (value * _dividendSplitPercentage) / DIVISOR;
        uint256 treasuryAmount = value - dividendAmount;

        // Distribute dividends
        if (dividendAmount > 0) {
            _dividendDistributor.distribute{value: dividendAmount}(address(0), dividendAmount);
        }

        // Transfer to treasury
        if (treasuryAmount > 0) {
            (bool success,) = _treasury.call{value: treasuryAmount}("");
            if (!success) {
                revert EthTransferFailed();
            }
        }
    }
}
