pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

import {BaseTest} from "./TestBase.sol";
import {DividendDistributor} from "../src/DividendDistributor.sol";

contract DividendDistributorFuzzTest is BaseTest {
    function testFuzz_DividendDistributor_Distribute(uint256 amount) external {
        // Assume amount is less than maxUint256 / 1e18 to avoid overflow
        vm.assume(amount < type(uint256).max / 1e18);
        vm.assume(amount > 0);
        _depositAndSweep(address(token1), amount);

        uint256 shareHolder1Claimable;
        uint256 shareHolder2Claimable;
        {
            uint256 perShare = distributor.dividendPerShare(address(token1));
            uint256 shares = distributor.shares(SHAREHOLDER_1);
            shareHolder1Claimable = (shares * perShare) / 1e18;
        }

        {
            uint256 perShare = distributor.dividendPerShare(address(token1));
            uint256 shares = distributor.shares(SHAREHOLDER_2);
            shareHolder2Claimable = (shares * perShare) / 1e18;
        }

        uint256 totalClaimable = shareHolder1Claimable + shareHolder2Claimable;

        // shareholder1 claim
        vm.prank(SHAREHOLDER_1);
        distributor.claimDividend(address(token1));

        vm.prank(SHAREHOLDER_2);
        distributor.claimDividend(address(token1));

        uint256 totalClaimed = token1.balanceOf(SHAREHOLDER_1) + token1.balanceOf(SHAREHOLDER_2);
        assertEq(totalClaimed, totalClaimable);

        uint256 shareHolder1Balance = token1.balanceOf(SHAREHOLDER_1);
        assertEq(shareHolder1Balance, shareHolder1Claimable);

        uint256 shareHolder2Balance = token1.balanceOf(SHAREHOLDER_2);
        assertEq(shareHolder2Balance, shareHolder2Claimable);
    }

    function testFuzz_FeeOnTransferReverts(uint256 amount) public {
        vm.assume(amount > feePercentage_); // ensure amount is greater than fee
        vm.assume(amount < type(uint256).max / 1e18);

        feeToken.mint(address(this), amount);

        feeToken.approve(address(distributor), amount);
        vm.expectRevert(DividendDistributor.NoTokensTransferred.selector);
        distributor.distribute(address(feeToken), amount);
    }

    function testFuzz_BalanceDeltaInvariant(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount < type(uint256).max / 1e18);

        token1.mint(address(this), amount);
        token1.approve(address(distributor), amount);

        uint256 before = token1.balanceOf(address(distributor));
        token1.approve(address(distributor), amount);
        distributor.distribute(address(token1), amount);
        uint256 afterBal = token1.balanceOf(address(distributor));

        assertEq(afterBal - before, amount);
    }

    function testFuzz_EthBalanceDeltaInvariant(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount < type(uint256).max / 1e18);

        vm.deal(address(this), amount);

        uint256 before = address(distributor).balance;
        distributor.distribute{value: amount}(address(0), amount);
        uint256 afterBal = address(distributor).balance;

        assertEq(afterBal - before, amount);
    }
}

