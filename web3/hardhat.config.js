require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const RPC_URL = "https://rpc.ankr.com/mumbai";
module.exports = {
  defaultNetwork: "mumbai",
  networks: {
    hardhat: {
      chainId: 80001,
    },
    mumbai: {
      url: "https://rpc.ankr.com/mumbai",
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
