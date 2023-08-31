// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// IMPORTING CONTRACT
import "./Context.sol";

// CONTRACT
abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _transferOwnership(_msgSender());
  }

  modifier onlyOwner() {
    _checkOwner();
    _;
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }
}