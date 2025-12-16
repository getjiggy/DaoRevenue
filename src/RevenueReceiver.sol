pragma solidity ^0.8.24;
//SPDX-License-Identifier: MIT

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRevenueReceiver} from "./interfaces/IRevenueReceiver.sol";
import {RevenueSplitter} from "./RevenueSplitter.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract RevenueReceiver is IRevenueReceiver, RevenueSplitter, ReentrancyGuard {
    error NoRevenueToSweep();

    event RevenueReceived(address indexed sender, uint256 amount);
    event RevenueWithdrawn(address indexed receiver, uint256 amount);
    // modules that determine how to distribute revenue

    constructor(
        uint splitPercentage_,
        address dividendDistributor_, 
        address treasury_)
        RevenueSplitter(splitPercentage_, dividendDistributor_, treasury_) {
    }

    receive() external payable {
        emit RevenueReceived(msg.sender, msg.value);
    }

    function sweep(address _token) nonReentrant() public {
        if (_token == address(0)) {
            _sweepEth();
        } else {
            _sweepErc20(_token);
        }
        emit RevenueWithdrawn(
            msg.sender, _token == address(0) ? address(this).balance : IERC20(_token).balanceOf(address(this))
        );
    }

    function _sweepEth() internal {
        uint256 balance = address(this).balance;

        if (balance == 0) {
            revert NoRevenueToSweep();
        }

        _splitEthRevenue();
    }

    function _sweepErc20(address _token) internal {
        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));

        if (balance == 0) {
            revert NoRevenueToSweep();
        }
        
        _splitTokenRevenue(token);
    }
}
