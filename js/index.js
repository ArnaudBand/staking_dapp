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
    let isStakingPausedText;

    let startDate = await cObj.methods.getStakeStartDate().call();
    startDate = Number(startDate) * 1000;

    let endDate = await cObj.methods.getStakeEndDate().call();
    endDate = Number(endDate) * 1000;

    let stakeDays = await cObj.methods.getStakeDays().call();

    let days = Math.floor(Number(stakeDays) / 86400);

    let dayDisplay = days > 0 ? days + (days == 1 ? " day" : " days") : "";

    document.querySelectorAll(".Lock-period-value").forEach((element) => {
      element.innerHTML = `${dayDisplay}`;
    });

    let rewardBal = await cObj.methods.getUserEstimatedRewards(currentAddress).call();

    document.getElementById("user-reward-balance-value").innerHTML = `Reward: ${rewardBal / 10 ** 18} ${SELECT_CONTRACT[_NETWORK_ID].TOKEN.symbol}`;

    let balMainUser = currentAddress ? await oContractToken.methods.balanceOf(currentAddress).call() : "";
    balMainUser = Number(balMainUser) / 10 ** 18;

    document.getElementById("user-token-value").innerHTML = `Balance: ${balMainUser} ${SELECT_CONTRACT[_NETWORK_ID].TOKEN.symbol}`;

    let currentDate = new Date().getTime();

    if(isStakingPaused) {
      isStakingPausedText = "Paused";
    } else if(currentDate < startDate) {
      isStakingPausedText = "Locked";
    } else if(currentDate > endDate) {
      isStakingPausedText = "Ended";
    } else {
      isStakingPausedText = "Active";
    }

    document.querySelectorAll(".active-status-staking").forEach((element) => {
      element.innerHTML = `${isStakingPausedText}`;
    });

    if(currentDate > startDate && currentDate < endDate) {
      const ele = document.getElementById("countdown-time-value");
      generateCountdown(ele, endDate);

      document.getElementById("countdown-title-value").innerHTML = "Staking Ends In";

      if(currentDate < startDate) {
        const ele = document.getElementById("countdown-time-value");
        generateCountdown(ele, startDate);

        document.getElementById("countdown-title-value").innerHTML = "Staking Starts In";
      }

      document.querySelectorAll(".apy-value").forEach((element) => {
        element.innerHTML = `${cApy}%`;
      });
    }
  } catch (error) {
    console.lclearog("loadInitialData", error);
    notyf.error(
      `Unable to fetch data from ${SELECT_CONTRACT[_NETWORK_ID].STAKING[sClass].name}!\n Please try again later.`
    )
  }
}

function generateCountdown(ele, claimDate) {
  clearInterval(countdownGlobal);
  var countdownDate = new Date(claimDate).getTime();

  countdownGlobal = setInterval(function () {
    var now = new Date().getTime();
    var distance = countdownDate - now;

    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
    var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    var minutes = Math.floor((distance % (1000 * 60 * 60)) /  (1000 * 60)); 
    var seconds = Math.floor((distance % (1000 * 60)) / 1000);

    ele.innerHTML = `${days}d ${hours}h ${minutes}m ${seconds}s`;

    if (distance < 0) {
      clearInterval(countdownGlobal);
      ele.innerHTML = "EXPIRED";
    }
  }, 1000);
}

async function connectMe(_provider) {
  try {
    let _comn_res = await commonProviderDetector(_provider);
    console.log("connectMe", _comn_res);
    if (!_comn_res) {
      notyf.error("Please install metamask wallet");
      return;
    } else {
      let sClass = getSelectedTab();
      console.log("connectMe", sClass);
    }
  } catch (error) {
    notyf.error(error.message);
  }
}

async function stackTokens() {
  try {
    let nTokens = document.getElementById("amount-to-stack-value-new").value;

    if(!nTokens) {
      return
    }

    if(isNaN(nTokens)) {
      notyf.error("Please enter valid number of tokens");
      return;
    }

    nTokens = Number(nTokens);

    let tokenToTransfer = addDecimal(nTokens, 18);

    console.log("stackTokens", tokenToTransfer);

    let balMainUser = await oContractToken.methods.balanceOf(currentAddress).call();

    balMainUser = Number(balMainUser) / 10 ** 18;

    console.log("stackTokens", balMainUser);

    if(tokenToTransfer > balMainUser) {
      notyf.error("Insufficient balance");
      return;
    }

    let sClass = getSelectedTab(contractCall);
    console.log("stackTokens", sClass);

    let balMainAllowance = await oContractToken.methods.allowance(currentAddress, SELECT_CONTRACT[_NETWORK_ID].STAKING[sClass].address).call();

    if(Number(balMainAllowance) < tokenToTransfer) {
      approveTokenSpend(tokenToTransfer, sClass);
    } else {
      stackTokenMain(tokenToTransfer, sClass);
    }
  } catch (error) {
    console.log(error);
    notyf.dismiss(notification);
    notyf.error(formatEthErrorMsg(error));
  }
}

async function approveTokenSpend(_mint_fee_wei, sClass) {
  let gasEstimation;

  try {
    gasEstimation = await oContractToken.methods.approve(
      SELECT_CONTRACT[_NETWORK_ID].STAKING[sClass].address,
      _mint_fee_wei
    ).estimateGas({
      from: currentAddress,
    });
  } catch (error) {
    console.log(error);
    notyf.error(formatEthErrorMsg(error));
    return;
  }

  oContractToken.methods
    .approve(SELECT_CONTRACT[_NETWORK_ID].STAKING[sClass].address, _mint_fee_wei)
    .send({
      from: currentAddress,
      gas: gasEstimation,
    })
    .on("transactionHash", function (hash) {
      console.log("Transaction Hash", hash);
      notyf.dismiss(notification);
      notification = notyf.success("Transaction Initiated");
    })
    .on("receipt", function (receipt) {
      console.log(receipt);
      notyf.dismiss(notification);
      notification = notyf.success("Transaction Confirmed");
      stackTokenMain(_mint_fee_wei);
    })
    .catch((error) => {
      console.log(error);
      notyf.error(formatEthErrorMsg(error));
      return;
    });
}