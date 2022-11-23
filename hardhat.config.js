require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-solhint");
require("@nomiclabs/hardhat-etherscan");

const ALCHEMY_API_KEY = "fWzxVLWrHo_jJ8nL92nIVriH8CbJSc45";
const GOERLI_PRIVATE_KEY = "af3401a55a14d783b1416d40de7019533786485bd512d372ed3a2c5fc93d17d8";
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY],
    }
  },
  etherscan: {
    apiKey: {
      goerli: "2VR1ZFAVM95B528E9MSIQDME6YAU69HX95"
    },
    customChains: [
      {
        network: "goerli",
        chainId: 5,
        urls: {
          apiURL: "https://api-goerli.etherscan.io/api",
          browserURL: "https://goerli.etherscan.io"
        }
      }
    ]
  }
};
