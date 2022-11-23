// const hre = require("hardhat");
// async function main() {
//     const Stust_NFT_meta = await ethers.getContractFactory("Stust_NFT_meta");
//     const stust_nFT_meta = await Stust_NFT_meta.deploy();
//     await stust_nFT_meta.deployed();
  
//     console.log("Marketplace deployed to address:", stust_nFT_meta.address);
//   }
  
//   main()
//     .then(() => process.exit(0))
//     .catch(error => {
//       console.error(error);
//       process.exit(1);
//     });

    async function main() {
        const [deployer] = await ethers.getSigners();
      
        console.log("Deploying contracts with the account:", deployer.address);
      
        console.log("Account balance:", (await deployer.getBalance()).toString());
      
        const Stust_NFT_meta = await ethers.getContractFactory("Stust_NFT_meta");
        const stust_nFT_meta = await Stust_NFT_meta.deploy("Stust_NFT_meta"
        , "SNM"
        );
        await stust_nFT_meta.deployed("Stust_NFT_meta"
        , "SNM");
        console.log("Stust_NFT_meta address:", stust_nFT_meta.address);
      }
      
      main()
        .then(() => process.exit(0))
        .catch((error) => {
          console.error(error);
          process.exit(1);
        });