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
    uint256 rewardAmount; // Reward amount
    uint256 lastStakeTime; // Last stake timestamp
    uint256 lastRewardCalculationTime; // Last reward calculation time
    uint256 rewardsClaimedSoFar; // Total reward claimed so far
  }

  uint256 _minimumStakeAmount; // Minimum stake amount
  uint256 _maxStakeTokenLimit; // Maximum stake token limit
  uint256 _stakeEndDate; // Stake end date
  uint256 _stakeStartDate; // Stake start date
  uint256 _totalStakedTokens; // Total staked token
  uint256 _totalUsers; // Total users
  uint256 __stakeDays; // Stake days
  uint256 _earlyUnstakeFeePercentage; // Early unstake fee percentage
  bool _isStakingPaused; // Stake Status

  // Token contract address
  address private _tokenAddress;

  // APY
  uint256 _apyRate;
  uint256 public constant PERCENTAGE_DENOMINATOR = 10000;
  uint256 public constant APY_RATE_CHANGE_THRESHOLD = 10;

  // User address to user mapping
  mapping(address => User) private _users;

  event Stake(address indexed user, uint256 amount);
  event UnStake(address indexed user, uint256 amount);
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
    return _isStakingPaused;
  }

  /** 
   * @notice This function is used to get the current APY Rate
   * @return current APY Rate
   */
  function getAPY() external view returns (uint256) {
    return _apyRate;
  }

  /** 
   * @notice This function is used to get msg.sender's estimated reward amount
   * @return msg.sender's estimated reward amount
   */
  function getEstimatedRewards() external view returns (uint256) {
    (uint256 amount, ) = _getEstimatedRewards(msg.sender);
    return _users[msg.sender].rewardAmount + amount;
  }

  /** 
   * @notice This function is used to get withdrawable amount from contract
   */
  function getWithdrawableAmount() external view returns (uint256) {
    return IERC20(_tokenAddress).balanceOf(address(this)) - _totalStakedTokens;
  }

  /** 
   * @notice This function is used to get user's details
   * @param userAddress User's address to get details of
   * @return User struct
   */
  function getUser(address userAddress) external view returns (User memory) {
    return _users[userAddress];
  }

  /** 
   * @notice This function is used to check if a user is a stakeholder
   * @param _user Address of the user to check
   * @return True if user is a stakeholder, false otherwise
   */
  function isStakeHolder(address _user) external view returns (bool) {
    return _users[_user].stakeAmount != 0;
  }

  /* View Methods End */

  /* Owner Methods start */

  /**
   * @notice This function is used to update minimum staking amount
   */
  function updateMinimumStakingAmount(uint256 newAmount) external onlyOwner {
    _minimumStakingAmount = newAmount;
  }

  /**
   * @notice This function is used to update maximum staking amount
   */
  function updateMaximumStakingAmount(uint256 newAmount) external onlyOwner {
    _maximumStakingAmount = newAmount;
  }

  /**
   * @notice This function is used to update stake end date
   */
  function updateStakeEndDate(uint256 newDate) external onlyOwner {
    _stakeEndDate = newDate;
  }

  /**
   * @notice This function is used to update early unstake fee percentage
   */
  function updateEarlyUnstakeFeePercentage(uint256 newPercentage) external onlyOwner {
    _earlyUnstakeFeePercentage = newPercentage;
  }

  /**
   * @notice Stake tokens for specific user
   * @dev This function can be used to stake tokens for specific user
   * 
   * @param amount the ammount to stake
   * @param user user's address
   */
  function stakeForUser(uint256 amount, address user) external onlyOwner nonReentrant {
    _stakeTokens(amount, user);
  }

  /**
   * @notice enable/disable staking
   * @dev This function can be to toggle staking status
   */
  function toggleStakingStatus() external onlyOwner {
    _isStakingPaused = !_isStakingPaused;
  }

  /**
   * @notice Withdraw the specified amount if possible
   * @dev This function can be used to withdraw the availabe tokens with this contract to the caller
   * @param amount the withdraw's amount
   */
  function withdraw(uint256 amount) external onlyOwner nonReentrant {
    require(this.getWithdrawableAmount() >= amount, "TokenStaking: not enough withdrawable tokens");
    IERC20(_tokenAddress).transfer(msg.sender, amount);
  }

  /* Owner Methods End */

  /* User Methods Start */

  /**
   * @notice this function is used to stake tokens
   * @param _amount Amount of tokens to be staked
   */
  function stakeTokens(uint256 _amount) external nonReentrant {
    _stakeTokens(_amount, msg.sender);
  }

  function _stakingTokens(uint256 _amount, address user_) private {
    require(!_isStakingPaused, "TokenStaking: Staking is paused");
    uint256 currentTime = getCurrentTime();
    require(currentTime > _stakeStartDate, "TokenStaking: Staking has not started yet");
    require(currentTime < _stakeEndDate, "TokenStaking: Staking has ended");
    require(_totalStakedTokens + _amount <= _maxStakeTokenLimit, "TokenStaking: Maximum staking limit reached");
    require(_amount > 0, "TokenStaking: Amount should be greater than 0");
    require(_amount >= _minimumStakingAmount, "TokenStaking: Amount should be greater than minimum staking amount");

    if(_users[user_].stakedAmount != 0) {
      _calculateRewards(user_);
    } else {
      _users[user_].lastRewardCalculationTime = currentTime;
      _totalUsers += 1;
    }

    _users[user_].stakedAmount += _amount;
    _users[user_].lastStakeTime = currentTime;

    _totalStakedTokens += _amount;

    require(
      IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount), "TokenStaking: failed to transfer"
    );
    emit Stake(user_, _amount);
  }

  /**
   * @notice this function is used to unstake tokens
   * @param _amount Amount of tokens to be unstaked
   */
  function unstake(uint256 _amount) external nonReentrant whenTreasuryHasBakance(_amount) {
    address user = msg.sender;
    require(_amount > 0, "TokenStaking: Amount should be greater than 0");
    require(this.isStakeHolder(user), "TokenStaking: not a stakeholder");
    require(_users[user].stakedAmount >= _amount, "TokenStaking: Amount should be less than staked amount");

    // Calculate User's rewards
    _calculateRewards(user);

    uint256 feeEarlyUnstake;

    if(getCurrentTime() <= _users[user].lastStakeTime + _stakeDays) {
      feeEarlyUnstake = ((_amount + _earlyUnstakeFeePercentage) / PERCENTAGE_DENOMINATOR);
      emit EarlyUnStakeFee(user, feeEarlyUnstake);
    }

    uint256 amountToUnstake = _amount - feeEarlyUnstake;

    _users[user].stakedAmount -= _amount;
    _totalStakedTokens -= _amount;

    if(_users[user].stakedAmount == 0) {
      // delete _users[user]
      _totalUsers -= 1;
    }
    require(IERC20(_tokenAddress).transfer(user, amountToUnstake), "TokenStaking: failed to transfer");
    emit UnStake(user, _amount);
  }

  /**
   * @notice this function is used to claim rewards
   */
  function claimReward() external nonReentrant whenTreasusyHasBalance(_users[msg.sender].rewardAmount) {
    _calculateRewards(msg.sender);
    uint256 rewardAmount = _users[msg.sender].rewardAmount;

    require(rewardAmount > 0, "TokenStaking: no reward to claim");
    require(IERC20(_tokenAddress).transfer(msg.sender, rewardAmount), "TokenStaking: failed to transfer");
    _users[msg.sender].rewardAmount = 0;
    _users[msg.sender].rewardsClaimedSoFar += rewardAmount;
  }

  /* User Methods End */

  /* Private Helper Methods Start */

  /**
   * @notice This function is used to calculate rewards for a user
   * @param _user Address of the user
   */
  function _calculaterewards(address _user) private {
    (uint256 userReward, uint256 currentTime) = _getUserEstimatedRewards(_user);
    _users[_user].rewardAmount += userReward;
    _users[_user].lastRewardCalculationTime = currentTime;
  }

  /**
   * @notice This function is used to get estimated rewards for user
   * @param _user Address of the user
   * @return estimated rewards for the user
   */
  function _getUserEstimatedRewards(address _user) private view returns (uint256, uint256) {
    uint256 userReward;
    uint256 userTimestamp = _users[_user].lastRewardCalculationTime;

    uint256 currentTimw = getCurrentTime();

    if(currentTime > _users[_user].lastStakeTime + _stakeDays) {
      currentTime = _users[user].lastStakeTime + _stakeDays;
    }

    uint256 totalStakedTime = currentTime - userTimestamp;
    userReward += ((totalStakedTime * _users[_user].stakedAmount * _apyRate) / 365 days) / PERCENTAGE_DENOMINATOR;
    return (userReward, currentTime);
  }
}