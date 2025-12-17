pragma solidity ^0.8.24;
//SPDX-License-Identifier: MIT

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRevenueReceiver} from "./interfaces/IRevenueReceiver.sol";
import {RevenueSplitter} from "./RevenueSplitter.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract RevenueReceiver is IRevenueReceiver, RevenueSplitter, ReentrancyGuard {
    error NoRevenueToSweep();

    event RevenueReceived(address indexed sender, uint256 amount);
    event RevenueWithdrawn(address indexed receiver, address indexed token, uint256 amount);
    // modules that determine how to distribute revenue

    constructor(uint16 splitPercentage_, address dividendDistributor_, address treasury_)
        RevenueSplitter(splitPercentage_, dividendDistributor_, treasury_)
    {}

    receive() external payable {
        emit RevenueReceived(msg.sender, msg.value);
    }

    function sweep(address token) public nonReentrant {
        uint balance;
        if (token == address(0)) {
            balance = address(this).balance;
            _sweepEth();
        } else {
            balance = IERC20(token).balanceOf(address(this));
            _sweepErc20(token);
        }

        emit RevenueWithdrawn(
            msg.sender, token, balance
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
