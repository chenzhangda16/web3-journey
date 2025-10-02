// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Counter {
    uint256 public number;
    function set(uint256 n) external { number = n; }
    function inc() external { number += 1; }
}
