loadInitialData("sevenDays");
connectMe("metamask_wallet");

function connectWallet() {};

function openTab(event, name) {
  console.log("openTab", name);
  contractCall = name;
  getSelectedTab(name);
  loadInitialData(name);
}


const loadInitialData = async (sClass) => {
  console.log("loadInitialData", sClass);

  try {
    clearInterval(countdownGlobal);

    let cObj = new web3Main.eth.Contract(
      SELECT_CONTRACT[_NETWORK_ID].STAKING.abi,
      SELECT_CONTRACT[_NETWORK_ID].STAKING[sClass].address
    );

    // ID ELEMENT DATA
    let totalUsers = await cObj.methods.getTotalUsers().call();
    let cApy = await cObj.methods.getAPY().call();

    // User details
    let userDetail = await cObj.methods.getUser(currentAddress).call();

    const user = {
      lastRewardCalculationTime: userDetail.lastRewardCalculationTime,
      lastStakeTime: userDetail.lastStakeTime,
      stakedAmount: userDetail.stakedAmount,
      rewardAmount: userDetail.rewardAmount,
      rewardsClaimedSoFar: userDetail.rewardsClaimedSoFar,
      address: currentAddress,
    };

    localStorage.setItem("User", JSON.stringify(user));

    let userDetailBal = userDetail.stakedAmount / 10 ** 18;

    // ID ELEMENT DATA
    document.getElementById("total-locked-user-token").innerHTML = `${userDetailBal}`;
    document.getElementById("num-of-stackers-value").innerHTML = `${cApy}%`;

    // CLASS ELEMENT DATA
    let totalLockedTokens = await cObj.methods.getTotalStakedTokens().call();
    let earlyUnstakeFee = await cObj.methods.getEarlyUnstakeFeePercentage().call();

    // ELEMENT DATA
    document.getElementById("total-locked-tokens-value").innerHTML = `${totalLockedTokens / 10 ** 18} ${SELECT_CONTRACT[_NETWORK_ID].TOKEN.symbol}`;
    document.querySelectorAll(".early-unstake-fee-value").forEach((e) => {
      e.innerHTML = `${earlyUnstakeFee / 100}%`;
    });

    let minStakeAmount = await cObj.methods.getMinimumStakeAmount().call();
    // let maxStakeAmount = await cObj.methods.getMaximumStakeAmount().call();

    let minA;
    if(minStakeAmount) {
      minA = `${minStakeAmount / 10 ** 18} ${SELECT_CONTRACT[_NETWORK_ID].TOKEN.symbol}`;
    } else {
      minA = "0";
    }

    document.querySelectorAll(".Minimum-Staking-Amount").forEach((e) => {
      e.innerHTML = `${minA}`;
    });

    document.querySelectorAll(".Maximum-Staking-Amount").forEach((e) => {
      e.innerHTML = `${(1000000).toLocaleString()} ${SELECT_CONTRACT[_NETWORK_ID].TOKEN.symbol}`;
    });

    let isStakingPaused = await cObj.methods.getStakeStatus().call();
    let isStakingPausedTextl;

    let startDate = await cObj.methods.getStakeStartDate().call();
    startDate = Number(startDate) * 1000;

    let endDate = await cObj.methods.getStakeEndDate().call();
    endDate = Number(endDate) * 1000;

    let stakeDays = await cObj.methods.getStakeDays().call();

    let days = Math.floor(Number(stakeDays) / 86400);

    let dayDisplay = days > 0 ? days + (days == 1 ? " day" : " days") : "";

    document.querySelectorAll(".Lock-period-value").forEach((element) => {
      element.innerHTML = `${dayDisplay}`;
    })
  } catch (error) {
    
  }
}