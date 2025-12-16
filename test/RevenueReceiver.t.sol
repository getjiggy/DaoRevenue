pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

import "forge-std/Test.sol";

import {RevenueReceiver} from "../src/RevenueReceiver.sol";
import {DividendDistributor} from "../src/DividendDistributor.sol";
import {MockErc20} from "./utils/MockErc20.sol";

contract RevenueReceiverTest is Test {
    RevenueReceiver private receiver;
    DividendDistributor private distributor;
    MockErc20 private shareToken;
    MockErc20 private token1;
    MockErc20 private token2;

    address private constant SHAREHOLDER_1 = address(0x1);
    address private constant SHAREHOLDER_2 = address(0x2);

    address private treasury = address(0xDEAD);

    function setUp() public {
        shareToken = new MockErc20("Share Token", "SHR");
        token1 = new MockErc20("Token 1", "TK1");
        token2 = new MockErc20("Token 2", "TK2");

        distributor = new DividendDistributor(address(shareToken));
        receiver = new RevenueReceiver(0.5 ether, address(distributor), treasury);

        // Mint share tokens to shareholders
        shareToken.mint(SHAREHOLDER_1, 1000 ether);
        shareToken.mint(SHAREHOLDER_2, 1000 ether);
    }

    function _depositAndSweep(address tokenAddress, uint256 amount) internal {
        MockErc20 token = MockErc20(tokenAddress);
        token.mint(address(receiver), amount);
        vm.prank(address(this));
        receiver.sweep(tokenAddress);
    }

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
