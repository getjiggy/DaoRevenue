pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRevenueSplitter {
    /// @notice Distributes dividends to shareholders.
    function splitTokenRevenue(IERC20 token) external;

    /// @notice Distributes dividends to shareholders in ETH.
    function splitEthRevenue() external payable;
}
