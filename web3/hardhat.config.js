require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const RPC_URL = "https://rpc-mumbai.maticvigil.com/";
module.exports = {
  defaultNetwork: "Polygon Mumbai",
  networks: {
    hardhat: {
      chainId: 80001,
    },
    polygon_mumbai: {
      url: "https://rpc-mumbai.maticvigil.com/",
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
