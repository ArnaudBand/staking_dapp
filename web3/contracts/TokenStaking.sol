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
  bool _isStakingPause; // Stake Status

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

  // MODIFIERS
   modifier whenTreasuryHasBakance(uin256 amount) {
    require(IERC20(_tokenAddress).balanceOf(address(this)) >= amount, "Treasury has no balance");
    _;
  }


  function initialize(
    address owner_,
    address tokenAddress_,
    uint256 apyRate_,
    uint256 minimumStakeAmount_,
    uint256 maxStakeTokenLimit_,
    uint256 stakeStartDate_,
    uint256 stakeEndDate_,
    uint256 stakeDays_,
    uint256 earlyUnstakeFeePercentage_
  ) public virtual initializer {
    __TokenStaking_init_unchained(
      owner_,
      tokenAddress_,
      apyRate_,
      minimumStakeAmount_,
      maxStakeTokenLimit_,
      stakeStartDate_,
      stakeEndDate_,
      stakeDays_,
      earlyUnstakeFeePercentage_
    );
  }

  function __TokenStaking_init_unchained(
    address owner_,
    address tokenAddress_,
    uint256 apyRate_,
    uint256 minimumStakeAmount_,
    uint256 maxStakeTokenLimit_,
    uint256 stakeStartDate_,
    uint256 stakeEndDate_,
    uint256 stakeDays_,
    uint256 earlyUnstakeFeePercentage_
  ) internal onlyInitializing {
    require(apyRate_ <= 10000, "TokenStaking: APY rate should be less than 10000");
    require(stakeDays_ > 0, "TokenStaking: Stake days should be greater than 0");
    require(tokenAddress_ != address(0), "TokenStaking: Token address should not be 0");
    require(stakeStartDate_ < stakeEndDate_, "TokenStaking: Stake start date should be less than stake end date");

    _transferOwnership(owner_);
    _tokenAddress = tokenAddress_;
    _apyRate = apyRate_;
    _minimumStakeAmount = minimumStakeAmount_;
    _maxStakeTokenLimit = maxStakeTokenLimit_;
    _stakeStartDate = stakeStartDate_;
    _stakeEndDate = stakeEndDate_;
    __stakeDays = stakeDays_;
    _earlyUnstakeFeePercentage = earlyUnstakeFeePercentage_;
  }
  
  /** 
   * @notice This function is used to get the minimun staking amount
   */
  function getMinimumStakeAmount() external view returns (uint256) {
    return _minimumStakeAmount;
  }

  /** 
   * @notice This function is used to get the maximum staking amount
   */
  function getMaxStakeTokenLimit() external view returns (uint256) {
    return _maxStakeTokenLimit;
  }

  /** 
   * @notice This function is used to get the stake start date
   */
  function getStakeStartDate() external view returns (uint256) {
    return _stakeStartDate;
  }

  /** 
   * @notice This function is used to get the stake end date
   */
  function getStakeEndDate() external view returns (uint256) {
    return _stakeEndDate;
  }

  /** 
   * @notice This function is used to get the total staked tokens
   */
  function getTotalStakedTokens() external view returns (uint256) {
    return _totalStakedTokens;
  }

  /** 
   * @notice This function is used to get the total users
   */
  function getTotalUsers() external view returns (uint256) {
    return _totalUsers;
  }

  /** 
   * @notice This function is used to get the stake days
   */
  function getStakeDays() external view returns (uint256) {
    return __stakeDays;
  }

  /** 
   * @notice This function is used to get the early unstake fee percentage
   */
  function getEarlyUnstakeFeePercentage() external view returns (uint256) {
    return _earlyUnstakeFeePercentage;
  }

  /** 
   * @notice This function is used to get the stake status
   */
  function getStakeStatus() external view returns (bool) {
    return _isStakingPause;
  }
}