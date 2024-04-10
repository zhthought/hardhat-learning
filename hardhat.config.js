require("@nomicfoundation/hardhat-toolbox");

const { vars } = require("hardhat/config");

// Go to https://infura.io, sign up, create a new API key
// in its dashboard, and store it as the "INFURA_API_KEY"
// configuration variable
const INFURA_API_KEY = vars.get("INFURA_API_KEY");

// Replace this private key with your Sepolia account private key
// To export your private key from Coinbase Wallet, go to
// Settings > Developer Settings > Show private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Store the private key as the "SEPOLIA_PRIVATE_KEY" configuration
// variable.
// Beware: NEVER put real Ether into testing accounts
const SEPOLIA_PRIVATE_KEY = vars.get("SEPOLIA_PRIVATE_KEY");

const ETHERSCAN_API_KEY = vars.get("ETHERSCAN_API_KEY");

const BSCTESTNET_API_KEY = vars.get("BSCTESTNET_API_KEY");

/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: {
    version: "0.8.24",
    // settings: {
    //   evmVersion: "shanghai",
    // },
  },

  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [SEPOLIA_PRIVATE_KEY],
    },
    bnbtestnet: {
      url: `https://bsc-testnet.core.chainstack.com/${BSCTESTNET_API_KEY}`,
      accounts: [SEPOLIA_PRIVATE_KEY],
    },
  },

  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};

// module.exports = {
//   solidity: "0.8.24",
// };

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("balance", "Prints an account's balance")
  .addParam("account", "The account's address")
  .setAction(async (taskArgs) => {
    const balance = await ethers.provider.getBalance(taskArgs.account);

    console.log(ethers.formatEther(balance), "ETH");
  });
