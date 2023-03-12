// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import { ERC1363 } from "contracts/w1/ERC1363.sol";

/**
 * @title SanctionableToken
 * @notice SanctionableToken is a token that allows the owner to ban specific addresses from sending & receiving tokens.
 */
contract SanctionableToken is ERC1363 {
  // Maps addresses to a bool indicating whether they are blacklisted
  mapping(address => bool) public isBlacklisted;

  constructor(string memory name, string memory symbol, uint256 maxSupply) ERC1363(name, symbol) {
    _mint(msg.sender, maxSupply);
  }

  /**
   * @notice Adds the specified address to the blacklist.
   * @param _address The address to blacklist.
   */
  function addToBlacklist(address _address) external onlyOwner {
    isBlacklisted[_address] = true;
  }

  /**
   * @notice Removes the specified address from the blacklist.
   * @param _address The address to be removed.
   */
  function removeFromBlacklist(address _address) external onlyOwner {
    isBlacklisted[_address] = false;
  }

  /* ==================== Internal Functions ==================== */

  /**
   * @notice Overrides the default ERC20 `_beforeTokenTransfer` function to add blacklist checks.
   * @param from The address of the sender.
   * @param to The address of the recipient.
   * @param amount The amount of tokens being transferred.
   */
  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
    super._beforeTokenTransfer(from, to, amount);

    require(!isBlacklisted[from], "From address is blacklisted");
    require(!isBlacklisted[to], "To address is blacklisted");
  }
}
