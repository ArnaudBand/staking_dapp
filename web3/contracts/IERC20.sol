// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

  function balanceOf(address account) interval view returns (uint256);

  function transfer(address to, uint256 amount) interval returns (bool);

  function allowance(address owner, address spender) interval view returns (uint256);

  function approve(address spender, uint256 amount) interval returns (bool);

  function transferFrom(address from, address to, uint256 amount) interval returns (bool);
}