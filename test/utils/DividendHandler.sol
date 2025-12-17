pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

import {DividendDistributor} from "../../src/DividendDistributor.sol";
import {MockErc20} from "./MockErc20.sol";
import {Test} from "forge-std/Test.sol";

contract DividendHandler is Test {
    DividendDistributor public distributor;
    MockErc20 public payoutToken;
    MockErc20 public shareToken;

    address[] private users;

    uint256 public totalDistributed;
    bool public hasDistributed;

    constructor(DividendDistributor _distributor, MockErc20 _payoutToken, MockErc20 _shareToken) {
        distributor = _distributor;
        payoutToken = _payoutToken;
        shareToken = _shareToken;

        // Pre-seed users
        for (uint256 i = 0; i < 5; i++) {
            address user = address(uint160(i + 10));
            users.push(user);
            MockErc20(shareToken).mint(user, 100 ether);
        }
    }

    function distribute(uint256 amount) external {
        vm.assume(amount > 0);
        vm.assume(amount < type(uint256).max / 1e18);

        payoutToken.mint(address(this), amount);
        payoutToken.approve(address(distributor), amount);
        distributor.distribute(address(payoutToken), amount);
        totalDistributed += amount;
        hasDistributed = true;
    }

    function claim(uint256 userIndex) external {
        if (!hasDistributed) {
            return;
        }
        vm.assume(userIndex < users.length);

        vm.prank(users[userIndex]);
        distributor.claimDividend(address(payoutToken));
    }

    function totalClaimed() external view returns (uint256 sum) {
        for (uint256 i; i < users.length; i++) {
            sum += distributor.claimedDividends(address(payoutToken), users[i]);
        }
    }

    function getUsers() external view returns (address[] memory) {
        return users;
    }
}
