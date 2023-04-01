require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();


// Replace this private key with your Sepolia account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Beware: NEVER put real Ether into testing accounts

module.exports = {
  solidity: "0.8.9",
  networks: {
    sepolia: {
      url: process.env.URL,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
