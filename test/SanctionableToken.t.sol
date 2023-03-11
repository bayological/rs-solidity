// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

// solhint-disable no-console
// solhint-disable func-name-mixedcase

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { SanctionableToken } from "contracts/w1/SanctionableToken.sol";

contract SanctionableTokenTest is Test {
  SanctionableToken public token;

  address public alice = makeAddr("alice");
  address public bob = makeAddr("bob");

  function setUp() public {
    token = new SanctionableToken("SanctionableToken", "SCT", 1000);
  }

  /* ---------- Constructor ---------- */

  function test_constructor_shouldMintSupplyToOwner() public {
    assertEq(token.balanceOf(address(this)), 1000);
  }

  /* ---------- Blacklist modifiers ---------- */

  function test_addToBlacklist_shouldUpdateBlacklistMappingCorrectly() public {
    assertFalse(token.isBlacklisted(alice));

    token.addToBlacklist(alice);
    assertTrue(token.isBlacklisted(alice));
  }

  function test_removeFromBlacklist_shouldUpdateBlacklistMappingCorrectly() public {
    token.addToBlacklist(alice);
    assertTrue(token.isBlacklisted(alice));

    token.removeFromBlacklist(alice);
    assertFalse(token.isBlacklisted(alice));
  }

  /* ---------- Transfer & Call ---------- */

  function test_transferAndCall_shouldRevertIfSenderIsBlacklisted() public {
    token.addToBlacklist(alice);
    assertTrue(token.isBlacklisted(alice));

    changePrank(alice);
    vm.expectRevert("From address is blacklisted");
    token.transferAndCall(bob, 10);
  }

  function test_transferAndCall_shouldRevertIfRecipientIsBlacklisted() public {
    token.addToBlacklist(bob);
    assertTrue(token.isBlacklisted(bob));

    changePrank(alice);
    vm.expectRevert("To address is blacklisted");
    token.transferAndCall(bob, 10);
  }

  function test_transferAndCall_whenDataIsProvided_shouldRevertIfSenderIsBlacklisted() public {
    token.addToBlacklist(alice);
    assertTrue(token.isBlacklisted(alice));

    changePrank(alice);
    vm.expectRevert("From address is blacklisted");
    token.transferAndCall(bob, 10, "0x");
  }

  function test_transferAndCall_whenDataIsProvided_shouldRevertIfRecipientIsBlacklisted() public {
    token.addToBlacklist(bob);
    assertTrue(token.isBlacklisted(bob));

    changePrank(alice);
    vm.expectRevert("To address is blacklisted");
    token.transferAndCall(bob, 10, "0x");
  }

  function test_transferAndCall_shouldTransferTokens() public {
    token.transferAndCall(bob, 10);
    assertEq(token.balanceOf(bob), 10);
  }

  /* ---------- Transfer From & Call ---------- */

  function test_transferFromAndCall_shouldRevertIfRecipientIsBlacklisted() public {
    token.addToBlacklist(bob);
    assertTrue(token.isBlacklisted(bob));

    // Alice needs to approve the transfer
    address prankBefore = msg.sender;
    changePrank(alice);
    token.approve(prankBefore, 10);
    changePrank(prankBefore);

    vm.expectRevert("To address is blacklisted");
    token.transferFromAndCall(alice, bob, 10);
  }

  function test_transferFromAndCall_shouldRevertIfSenderIsBlacklisted() public {
    token.addToBlacklist(alice);
    assertTrue(token.isBlacklisted(alice));

    // Alice needs to approve the transfer
    address prankBefore = msg.sender;
    changePrank(alice);
    token.approve(prankBefore, 10);
    changePrank(prankBefore);

    vm.expectRevert("From address is blacklisted");
    token.transferFromAndCall(alice, bob, 10);
  }

  function test_transferFromAndCall_whenDataIsProvided_shouldRevertIfRecipientIsBlacklisted() public {
    token.addToBlacklist(bob);
    assertTrue(token.isBlacklisted(bob));

    // Alice needs to approve the transfer
    address prankBefore = msg.sender;
    changePrank(alice);
    token.approve(prankBefore, 10);
    changePrank(prankBefore);

    vm.expectRevert("To address is blacklisted");
    token.transferFromAndCall(alice, bob, 10, "0x");
  }

  function test_transferFromAndCall_whenDataIsProvided_shouldRevertIfSenderIsBlacklisted() public {
    token.addToBlacklist(alice);
    assertTrue(token.isBlacklisted(alice));

    // Alice needs to approve the transfer
    address prankBefore = msg.sender;
    changePrank(alice);
    token.approve(prankBefore, 10);
    changePrank(prankBefore);

    vm.expectRevert("From address is blacklisted");
    token.transferFromAndCall(alice, bob, 10, "0x");
  }
}
