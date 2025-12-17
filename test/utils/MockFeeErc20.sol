pragma solidity ^0.8.24;
// SPDX-License-Identifier: MIT

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockFeeErc20 is ERC20 {
    uint256 private _feePercentage; // fee percentage in basis points (e.g., 100 = 1%)

    constructor(string memory name_, string memory symbol_, uint256 feePercentage_) ERC20(name_, symbol_) {
        _feePercentage = feePercentage_;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * _feePercentage) / 10000;
        uint256 amountAfterFee = amount - fee;

        _transfer(_msgSender(), address(this), fee); // Collect fee
        _transfer(_msgSender(), recipient, amountAfterFee);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * _feePercentage) / 10000;
        uint256 amountAfterFee = amount - fee;

        _transfer(sender, address(this), fee); // Collect fee
        _transfer(sender, recipient, amountAfterFee);

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }
}
