// SPDX-License-Identifier: MIT
// Foundry test (requires forge)
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../contracts/Counter.sol";

contract CounterTest is Test {
    Counter c;
    function setUp() public { c = new Counter(); }
    function testInc() public { c.inc(); assertEq(c.number(), 1); }
}
