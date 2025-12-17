pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT
import {BaseTest} from "./TestBase.sol";

contract receiverFuzzTest is BaseTest {
    function testFuzz_RevenueReceiver_SweepToken(uint256 tokenAmount) external {
        // Assume tokenAmount is less than maxUint256 / WAD to avoid overflow
        vm.assume(tokenAmount < type(uint256).max / 1e18);
        vm.assume(tokenAmount > 0);
        // Arrange
        token1.mint(address(receiver), tokenAmount);

        // Act
        receiver.sweep(address(token1));

        // Assert
        // receiver should have zero balance after sweep
        assertEq(token1.balanceOf(address(receiver)), 0);
        // dividend distributor should have balance * pct / 10000

        uint256 distributorShareToken = tokenAmount * splitPercentage / 10000;

        assertEq(token1.balanceOf(address(distributor)), distributorShareToken);

        // treasury should have balance - dividend share
        uint256 treasuryShareToken = tokenAmount - distributorShareToken;

        assertEq(token1.balanceOf(address(treasury)), treasuryShareToken);
    }

    function testFuzz_RevenueReceiver_SweepEth(uint256 ethAmount) external {
        // Assume ethAmount is less than maxUint256 / WAD to avoid overflow
        vm.assume(ethAmount < type(uint256).max / 1e18);
        vm.assume(ethAmount > 0);

        // Arrange
        vm.deal(address(receiver), ethAmount);

        // Act
        receiver.sweep(address(0));

        // Assert
        // receiver should have zero balance after sweep
        assertEq(address(receiver).balance, 0);
        // dividend distributor should have balance / 2
        uint256 distributorShareEth = ethAmount / 2;
        assertEq(address(distributor).balance, distributorShareEth);

        // treasury should have balance - dividend share
        uint256 treasuryShareEth = ethAmount - distributorShareEth;
        assertEq(address(treasury).balance, treasuryShareEth);
    }
}
