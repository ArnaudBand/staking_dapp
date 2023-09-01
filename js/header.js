const _NETWORK_ID = 80001;
let SELECT_CONTRACT = {};

SELECT_CONTRACT[_NETWORK_ID] = {
  network_name: 'Mumbai Testnet',
  explorer_url: 'https://mumbai.polygonscan.com',
  STACKING: {
    // 0xD4254966E18aFA537eB35d0d7d9f01BF25935B75
    sevenDays: {
      address: "0x51168d2D1B935932959Bd7617892a5C1DB7Fb0AA",
    },
    tenDays: {
      address: "0x18E6d0eb4Cf368b4089BdEE8158a46EAF5003aA3",
    },
    thirtyTwoDays: {
      address: "0xD4623098a915D254810dc9E8f210733E4108ebaD",
    },
    ninetyDays: {
      address: "0x4aafc4309Decf7Fc9cBD560a9c65A0052486f97b",
    },
    abi: [],
  },
  TOKEN: {
    symbol: "TBC",
    address: "0x00000",
    abi: [],
  },
};

/* countdown global */
let countdownGlobal;

/* wallet connection */
let web3;
let oContractToken;
let contractCall = "sevenDays";
let currentAddress;
let web3Main = new Web3("https://rpc.ankr.com/mumbai");

// Create an instance of the Notyf class
const notyf = new Notyf({
  duration: 3000,
  position: {
    x: "right",
    y: "bottom",
  },
});