pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

import "forge-std/Test.sol";
import {RevenueReceiver} from "../src/RevenueReceiver.sol";
import {DividendDistributor} from "../src/DividendDistributor.sol";
import {MockErc20} from "./utils/MockErc20.sol";
import {MockFeeErc20} from "./utils/MockFeeErc20.sol";

abstract contract BaseTest is Test {
    RevenueReceiver public receiver;
    DividendDistributor public distributor;
    MockErc20 public shareToken;
    MockErc20 public token1;
    MockErc20 public token2;
    MockFeeErc20 public feeToken;

    uint16 public splitPercentage = 5000; // 50%
    uint16 public feePercentage_ = 100; // 1%

    address public constant SHAREHOLDER_1 = address(0x1);
    address public constant SHAREHOLDER_2 = address(0x2);

    address[2] public shareholders = [SHAREHOLDER_1, SHAREHOLDER_2];

    address public treasury = address(0xDEAD);

    function setUp() public {
        shareToken = new MockErc20("Share Token", "SHR");
        token1 = new MockErc20("Token 1", "TK1");
        token2 = new MockErc20("Token 2", "TK2");
        feeToken = new MockFeeErc20("Fee Token", "FEE", feePercentage_); // 1% fee on transferp

        distributor = new DividendDistributor(address(shareToken));
        receiver = new RevenueReceiver(splitPercentage, address(distributor), treasury);

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
}
