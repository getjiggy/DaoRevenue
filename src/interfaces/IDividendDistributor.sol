pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

interface IDividendDistributor {
    /// @notice Distributes dividends to shareholders.
    function distribute(address token, uint256 amount) external payable;

    /// @notice Emitted when dividends are distributed.
    event DividendsDistributed(address token, uint256 amount);
}
