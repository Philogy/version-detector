// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICreate2Factory {
    function safeCreate2(bytes32 salt, bytes calldata initCode) external returns (address addr);
}
