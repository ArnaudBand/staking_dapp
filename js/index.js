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
  } catch (error) {
    
  }
}