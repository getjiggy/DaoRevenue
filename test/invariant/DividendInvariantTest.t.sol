pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

import {StdInvariant, Test} from "forge-std/Test.sol";
import {DividendDistributor} from "../../src/DividendDistributor.sol";
import {DividendHandler} from "../utils/DividendHandler.sol";
import {MockErc20} from "../utils/MockErc20.sol";

contract DividendInvariantTest is StdInvariant, Test {
    DividendDistributor distributor;
    DividendHandler handler;
    MockErc20 payoutToken;
    MockErc20 shareToken;

    function setUp() public {
        shareToken = new MockErc20("Share", "SHARE");
        payoutToken = new MockErc20("Payout", "PAY");

        distributor = new DividendDistributor(address(shareToken));

        handler = new DividendHandler(distributor, payoutToken, shareToken);

        targetContract(address(handler));
    }

    function invariant_TotalClaimsNeverExceedBalance() public {
        uint256 claimed = handler.totalClaimed();
        uint256 totalBalance;
        address[] memory users = handler.getUsers();
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 userBalance = payoutToken.balanceOf(users[i]);
            totalBalance += userBalance;
            assertEq(distributor.claimedDividends(address(payoutToken), user), userBalance);
        }
        assertEq(claimed, totalBalance);
    }

    function invariant_BalanceMatchesDistributedMinusClaimed() public {
        uint256 claimed = handler.totalClaimed();
        uint256 balance = payoutToken.balanceOf(address(distributor));
        assertEq(balance, handler.totalDistributed() - claimed);
    }

    function invariant_ClaimsNeverExceedLifetimeDistributed() public {
        uint256 claimed = handler.totalClaimed();
        assertLe(claimed, handler.totalDistributed());
    }
}
