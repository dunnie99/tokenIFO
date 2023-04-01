import { ethers } from "hardhat";


async function main() {
    const [owner] = await ethers.getSigners();

  //deploy nft token
  const tokenIFO = await ethers.getContractFactory("launchPadIFO");
  const launchToken = await tokenIFO.deploy();
  await launchToken.deployed();

  const launchPadTokenaddress = launchToken.address;

  console.log(`IFO LaunchPad Token deployed to ${launchPadTokenaddress}`);

///@info log nft details
   

  //// this is the CID..... QmdzDfQH5q7ViXGq7QMRBHLpoC8wGfHEFm4bBsD29hW5yS

  




}



// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});