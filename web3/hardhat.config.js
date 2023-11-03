require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const RPC_URL = "https://polygon-mumbai.g.alchemy.com/v2/Ep6g0hgDl0U_rAQ-T8kpfZul99smDNcx";
module.exports = {
  defaultNetwork: "Polygon Mumbai",
  networks: {
    hardhat: {
      chainId: 80001,
    },
    mumbai: {
      url: RPC_URL,
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
