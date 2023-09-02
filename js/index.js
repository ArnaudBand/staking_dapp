loadInitialData("sevenDays");
connectMe("metamask_wallet");

function connectWallet() {};

function openTab(event, name) {
  console.log("openTab", name);
  contractCall = name;
  getSelectedTab(name);
  loadInitialData(name);
}
