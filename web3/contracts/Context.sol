// SPDX-License-Identifier: UNLICENSED
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

abstract contract Context {
  function _msgSender() interval view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() interval view virtual returns (bytes calldata) {
    return msg.data;
  }
}