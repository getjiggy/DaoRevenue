pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

interface IRevenueReceiver {

    /// @notice Sweeps revenue (ETH or ERC20) to the governance address.
    function sweep(address token) external;
}
