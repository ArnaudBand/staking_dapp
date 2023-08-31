// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

// IMPORTING CONTRACT
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./Initializable.sol";
import "./IERC20.sol";

// CONTRACT
contract TokenStaking is Ownable, ReentrancyGuard, Initializable {
  struct User {
    uint256 stakedAmount; // Stake Amount
    uint256 rewardDebt; // Reward amount
    uint256 lastStakeTime; // Last stake timestamp
    uint256 lastRewardCaluculationTime; // Last reward calculation time
    uint256 rewardClaimsoFar; // Total reward claimed so far
  }

  uint256 _minimumStakeAmount; // Minimum stake amount
  uint256 _maxStakeTokenLimit; // Maximum stake token limit
  uint256 _stakeEndDate; // Stake end date
  uint256 _stakeStartDate; // Stake start date
  uint256 _totalStakedTokens; // Total staked token
  uint256 _totalUsers; // Total users
  uint256 __stakeDays; // Stake days
  uint256 _earlyUnstakeFeePercentage; // Early unstake fee percentage
  bool _isStakePause; // Is stake active

  // Token contract address
  address private _tokenAddress;

  // APY
  uint256 _apyRate;
  uint256 public constant PERCENTAGE_DENOMINATOR = 10000;
  uint256 public constant APY_RATE_CHANGE_THRESHOLD = 10;

  // User address to user mapping
  mapping(address => User) private _users;

  event Stake(address indexed user, uint256 amount);
  event Unstake(address indexed user, uint256 amount);
  event EarlyUnStakeFee(address indexed user, uint256 amount);
  event ClaimReward(address indexed user, uint256 amount);
}