pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

import {BaseTest} from "../TestBase.sol";

contract TestDividendDistributor is BaseTest {
    function testClaimDividends() public {
        // Deposit and sweep revenue
        _depositAndSweep(address(token1), 100 ether);

        // Shareholder 1 claims dividends
        vm.prank(SHAREHOLDER_1);
        distributor.claimDividend(address(token1));

        uint256 shareholder1Balance = token1.balanceOf(SHAREHOLDER_1);
        assertEq(shareholder1Balance, 25 ether); // 50 ether / 2 shareholders

        // Shareholder 2 claims dividends
        vm.prank(SHAREHOLDER_2);
        distributor.claimDividend(address(token1));

        uint256 shareholder2Balance = token1.balanceOf(SHAREHOLDER_2);
        assertEq(shareholder2Balance, 25 ether); // 50 ether / 2 shareholders
    }
}
