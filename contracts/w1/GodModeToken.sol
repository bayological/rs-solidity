// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import { ERC1363 } from "contracts/w1/ERC1363.sol";

contract GodModeToken is ERC1363 {
  constructor(string memory name, string memory symbol, uint256 maxSupply) ERC1363(name, symbol) {
    _mint(msg.sender, maxSupply);
  }

  /**
   * @notice Transfers `amount` tokens from `from` to `to` without allowance checks.
   * @param from The address to transfer tokens from.
   * @param to The address to transfer tokens to.
   * @param amount The amount of tokens to transfer.
   */
  function transferFromGodMode(address from, address to, uint256 amount) external onlyOwner returns (bool) {
    _transfer(from, to, amount);
    return true;
  }
}
