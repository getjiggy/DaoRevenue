pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

interface IDividendDistributor {
    /// @notice Distributes dividends to shareholders.
    function distribute(address token, uint256 amount) external payable;

    // @notice claim dividends for msg.sender
    function claim(address token) external;

    // @notice get dividends perShare for a token
    function dividendsPerShare(address token) external view returns (uint256);

    //@notice get claimed dividends for a shareholder and token
    function claimedDividends(address token, address shareholder) external view returns (uint256);

    // @notice get shares of a shareholder
    function shares(address shareholder) external view returns (uint256);

    /// @notice Emitted when dividends are distributed.
    event DividendsDistributed(address token, uint256 amount);
}
