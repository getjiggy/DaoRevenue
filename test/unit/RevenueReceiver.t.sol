pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

import {BaseTest} from "../TestBase.sol";

contract RevenueReceiverTest is BaseTest {
    function testSweepTokenRevenue() public {
        // Mint some revenue tokens to the receiver
        token1.mint(address(receiver), 100 ether);

        // Sweep the revenue
        vm.prank(address(this));
        receiver.sweep(address(token1));

        // check that the treasury received its share
        uint256 treasuryBalance = token1.balanceOf(treasury);
        assertEq(treasuryBalance, 50 ether);

        // check that the distributor has the correct amount for distribution
        uint256 distributorBalance = token1.balanceOf(address(distributor));
        assertEq(distributorBalance, 50 ether);
    }

    function testSweepEthRevenue() public {
        // Send some ETH to the receiver
        vm.deal(address(receiver), 100 ether);

        // Sweep the revenue
        vm.prank(address(this));
        receiver.sweep(address(0));

        // check that the distributor has the correct amount for distribution
        uint256 distributorBalance = address(distributor).balance;
        assertEq(distributorBalance, 50 ether);

        // check that the treasury received its share
        uint256 treasuryBalance = treasury.balance;
        assertEq(treasuryBalance, 50 ether);
    }
}
