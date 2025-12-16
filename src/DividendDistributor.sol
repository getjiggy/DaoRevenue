pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DividendDistributor is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 private _shareToken;
    uint256 private constant WAD = 1 ether;

    mapping(address => uint256) private _perShareDividend;
    mapping(address => mapping(address => uint256)) private _claimedDividends;

    error NoSharesExist();
    error NoTokensTransferred();
    error InvalidDividendAmount();
    error EthClaimFailed();

    constructor(address shareToken_) {
        _shareToken = IERC20(shareToken_);
    }

    function distribute(address token, uint256 amount) external payable nonReentrant {
        if (amount == 0) {
            revert InvalidDividendAmount();
        } else if (token == address(0) && msg.value != amount) {
            revert InvalidDividendAmount();
        }

        uint256 balanceToDistribute = amount;

        if (token != address(0)) {
            IERC20(token).safeTransferFrom(msg.sender, address(this), balanceToDistribute);
        }

        uint256 totalShares = _shareToken.totalSupply();

        if (totalShares == 0) {
            revert NoSharesExist();
        }

        _perShareDividend[token] += (balanceToDistribute * WAD) / totalShares;
    }

    function claimDividend(address token) external nonReentrant {
        address shareholder = msg.sender;
        uint256 shareholderShares = _shareToken.balanceOf(shareholder);
        uint256 totalDividend = (_perShareDividend[token] * shareholderShares) / WAD;
        uint256 claimedDividend = _claimedDividends[token][shareholder];
        uint256 payableDividend = totalDividend - claimedDividend;

        if (payableDividend > 0) {
            _claimedDividends[token][shareholder] += payableDividend;

            if (token == address(0)) {
                (bool success,) = shareholder.call{value: payableDividend}("");
                if (!success) {
                    revert EthClaimFailed();
                }
            } else {
                IERC20(token).safeTransfer(shareholder, payableDividend);
            }
        }
    }
}
