// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract Theblockchaincoders {
  string public name = "Theblockchaincoders";
  string public symbol = "TBC";
  string public standard = "Theblockchaincoders v1.0";
  uint256 public totalSupply;
  address public ownerOfContract;
  uint256 public _userId;

  uint256 constant initialSupply = 1000000 * (10 ** 18);

  address[] public holderToken;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  mapping(address => TokenHolderInfo) public tokenHolderInfos;

  struct TokenHolderInfo {
    uint256 _tokenId;
    address _from;
    address _to;
    uint256 _totalToken;
    bool _tokenHolder;
  }


  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  constructor() {
    ownerOfContract = msg.sender;
    totalSupply = initialSupply;
    balanceOf[msg.sender] = initialSupply;
  }

  function inc() internal {
    return _userId++;
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(balanceOf[msg.sender] >= _value);
    inc();

    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;

    TokenHolderInfo storage tokenHolderInfo = tokenHolderInfos[_to];

    tokenHolderInfo._tokenId = _userId;
    tokenHolderInfo._to = _to;
    tokenHolderInfo._from = msg.sender;
    tokenHolderInfo._totalToken = _value;
    tokenHolderInfo._tokenHolder = true;

    holderToken.push(_to);

    emit Transfer(msg.sender, _to, _value);

    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
}