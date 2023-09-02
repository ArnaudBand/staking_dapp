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
  } catch (error) {
    
  }
}