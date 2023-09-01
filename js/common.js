/**
 * @notice This function is used to connect to the injected provider
 * @param {*} _provider 
 * @returns  
 */
async function commonProviderDetector(_provider) {
  if(_provider == "metamask_wallet") {
    if(window.ethereum && window.ethereum.providers) {
      const metamaskProvider = window.ethereum.providers.find(provider => provider.isMetaMask);
      if(metamaskProvider) {
        window.ethereum.providers = [metamaskProvider];
        return await commonInjectedConnect(metamaskProvider, _provider);
      } else {
        console.log("Metamask not found");
        window.open("https://metamask.io/download.html", "_blank").focus();
        return false;
      }
    } else if(window.ethereum) {
      return await commonInjectedConnect(window.ethereum, _provider);
    } else {
      console.log("Metamask not found");
      
      try {
        window.open("https://metamask.io/download.html", "_blank").focus();
      } catch(e) {}
      return false;
    }
  }
};

async function commonInjectedConnect(_provider, _provider_name) {
  await _provider.enable();
  setWeb3Events(_provider);

  web3 = new Web3(_provider);

  // Get the current chain id
  let currentNetworkId = await web3.eth.getChainId();
  currentNetworkId = currentNetworkId.toString();
  console.log("currentNetworkId", currentNetworkId);

  // Get the current account
  let accounts = await web3.eth.getAccounts();
  console.log("accounts", accounts);

  currentAddress = accounts[0].toLowerCase();

  // Check if the current network is supported
  if(currentNetworkId != _NETWORK_ID) {
    console.log("Network not supported");
    notyf.error(`Please connect Wallet on ${SELECT_CONTRACT[_NETWORK_ID].network_name}`);
    return false;
  }
  oContractToken = new web3.eth.Contract(SELECT_CONTRACT[_NETWORK_ID].TOKEN.abi, SELECT_CONTRACT[_NETWORK_ID].TOKEN.address);
  return true;
};

function setWeb3Events(_provider) {
  _provider.on("accountsChanged", function (accounts) {
    console.log("accountsChanged", accounts);
    if(!accounts.length) {
      logout();
    } else {
      currentAddress = accounts[0];
      let sClass = getSelectedTab();
    }
  });

  // Handle chainChanged
  _provider.on("chainChanged", function (chainId) {
    console.log("chainChanged", chainId);
    logout();
  });

  // Handle session connection
  _provider.on("connect", function () {
    console.log("connect");
    logout();
  });

  // Handle session disconnection
  _provider.on("disconnect", function (code, reason) {
    console.log("disconnect");
    localStorage.clear();
    logout();
  });
}

function logout() {
  localStorage.clear();
  window.location.reload();
}

function addDecimal(number, decimal) {
  // Convert the number to a string and split it into two parts using the decimal point
  const numberParts = `${number}`.split(".");

  // Check if there is a decimal part (i.e., if the number contains a decimal point)
  if (numberParts[1]) {
    // If the decimal part has more digits than the desired decimal places, truncate it
    if (numberParts[1].length > decimal) {
      numberParts[1] = numberParts[1].slice(0, decimal);
    }

    // Concatenate the integer part, truncated decimal part, and additional zeros to achieve the desired decimal places
    return numberParts[0] + numberParts[1] + "0".repeat(decimal - numberParts[1].length);
  } else {
    // If there is no decimal part, add zeros to achieve the desired decimal places
    return numberParts[0] + "0".repeat(decimal);
  }
}

function formatEthErrorMsg(error) {
  try {
    var eFrom = error.message.indexOf("{");
    var eTo = error.message.lastIndexOf("}");
    var eM1 = error.message.indexOf("TokenStaking: ");
    var eM2 = error.message.indexOf("ERc20: ");
    var eM3 = error.message.indexOf("Internal JSON-RPC error.");

    if(eFrom != -1 && eTo != -1 && (eM1 != -1 || eM2 != -1)) {
      var eMsgTemp = JSON.parse(error.message.substr(eFrom, eTo));
      var eMsg = eM3 != -1 ? eMsgTemp.message : eMsgTemp.originalError.message;

      if(eM1 != -1) {
        return eMsg.split("TokenStaking: ", "");
      } else {
        return eMsg.split("ERC20: ", "");
      }
    } else {
      return error.message;
    }
  } catch (e) {
    console.log(e);
    return "Unknown error";
  }
}