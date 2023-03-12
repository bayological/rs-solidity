// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import { IERC1363 } from "oz-contracts/interfaces/IERC1363.sol";
import { IERC1363Receiver } from "oz-contracts/interfaces/IERC1363Receiver.sol";

import { IERC165 } from "oz-contracts/utils/introspection/IERC165.sol";
import { ERC165 } from "oz-contracts/utils/introspection/ERC165.sol";

import { ERC20 } from "oz-contracts/token/ERC20/ERC20.sol";

import { Ownable } from "oz-contracts/access/Ownable.sol";
import { Address } from "oz-contracts/utils/Address.sol";

contract ERC1363 is ERC20, ERC165, Ownable, IERC1363 {
  using Address for address;

  constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

  /**
   * @notice Returns true if the contract implements the interface defined by
   * `interfaceId`
   * @param interfaceId The interface identifier, as specified in ERC-165.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
    // 0x4bbee2df == identifier for transferAndCall functions ONLY(not approveAndCall) defined in IERC1363
    return interfaceId == 0x4bbee2df || super.supportsInterface(interfaceId);
  }

  /**
   * @notice Transfers `amount` tokens from the caller's account to `to` and then calls `onTransferReceived` on `to`.
   * @param to The address of the recipient.
   * @param amount The amount of tokens to transfer.
   * @return True if the transfer succeeded, false otherwise.
   */
  function transferAndCall(address to, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), to, amount);
    return _callOnTransferReceived(to, amount, "");
  }

  /**
   * @notice Transfers `amount` tokens from the caller's account to `to` and then calls `onTransferReceived` on `to` with `data`.
   * @param to The address of the recipient.
   * @param amount The amount of tokens to transfer.
   * @param data The data to pass to `onTransferReceived`.
   * @return True if the transfer succeeded, false otherwise.
   */
  function transferAndCall(address to, uint256 amount, bytes memory data) external returns (bool) {
    _transfer(_msgSender(), to, amount);
    return _callOnTransferReceived(to, amount, data);
  }

  /**
   * @notice Transfers `amount` tokens from `from` to `to` and then calls `onTransferReceived` on `to`.
   * @param from The address of the sender.
   * @param to The address of the recipient.
   * @param amount The amount of tokens to transfer.
   * @return True if the transfer succeeded, false otherwise.
   */
  function transferFromAndCall(address from, address to, uint256 amount) external returns (bool) {
    transferFrom(from, to, amount);
    return _callOnTransferReceived(to, amount, "");
  }

  /**
   * @notice Transfers `amount` tokens from `from` to `to` and then calls `onTransferReceived` on `to` with `data`.
   * @param from The address of the sender.
   * @param to The address of the recipient.
   * @param amount The amount of tokens to transfer.
   * @param data The data to pass to `onTransferReceived`.
   * @return True if the transfer succeeded, false otherwise.
   */
  function transferFromAndCall(address from, address to, uint256 amount, bytes memory data) external returns (bool) {
    transferFrom(from, to, amount);
    return _callOnTransferReceived(to, amount, data);
  }

  function approveAndCall(address spender, uint256 value) external returns (bool) {
    revert("approveAndCall not supported");
  }

  function approveAndCall(address spender, uint256 value, bytes memory data) external returns (bool) {
    revert("approveAndCall not supported");
  }

  /* ==================== Internal Functions ==================== */

  /**
   * @notice Calls `onTransferReceived` on the recipient if the recipient is a contract.
   * @param to The address of the recipient.
   * @param amount The amount of tokens being transferred.
   * @param data The data to pass to `onTransferReceived`.
   * @return True if the recipient is not a contract or if the recipient is a contract that returns the correct magic value.
   */
  function _callOnTransferReceived(address to, uint256 amount, bytes memory data) internal returns (bool) {
    // Check if recipient is a contract and if it supports the IERC1363Receiver.`onTransferReceived` function
    if (to.isContract() && IERC165(to).supportsInterface(0x88a7ca5c)) {
      try IERC1363Receiver(to).onTransferReceived(_msgSender(), _msgSender(), amount, data) returns (
        bytes4 returnData
      ) {
        return returnData == IERC1363Receiver(to).onTransferReceived.selector;
      } catch {
        revert("onTransferReceived call failed");
      }
    } else {
      return true;
    }
  }
}
