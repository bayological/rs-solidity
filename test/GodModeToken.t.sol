// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

// solhint-disable no-console
// solhint-disable func-name-mixedcase

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { GodModeToken } from "contracts/w1/GodModeToken.sol";

contract GodModeTokenTest is Test {
  GodModeToken public token;

  address public alice = makeAddr("alice");
  address public bob = makeAddr("bob");
  address public notGod = makeAddr("notGod");

  function setUp() public {
    token = new GodModeToken("GodModeToken", "GMT", 1000);

    // Send some tokens to alice
    token.transfer(alice, 100);

    // Send some tokens to bob
    token.transfer(bob, 100);
  }

  function test_transferFromGodMode_whenCalledByNonOwner_shouldRevert() public {
    changePrank(notGod);
    vm.expectRevert("Ownable: caller is not the owner");
    token.transferFromGodMode(alice, bob, 10);
  }

  function test_transferFromGodMode_whenCalledByOwner_shouldTransferTokens() public {
    uint256 aliceBalanceBefore = token.balanceOf(alice);
    uint256 bobBalanceBefore = token.balanceOf(bob);

    token.transferFromGodMode(alice, bob, 10);

    uint256 aliceBalanceAfter = token.balanceOf(alice);
    uint256 bobBalanceAfter = token.balanceOf(bob);

    assertEq(aliceBalanceAfter, aliceBalanceBefore - 10);
    assertEq(bobBalanceAfter, bobBalanceBefore + 10);
  }
}
