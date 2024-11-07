require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
  try {
    const Loterie = await ethers.getContractFactory("Loterie");
    console.log("Contract factory created:", Loterie);

    const loterie = await Loterie.deploy();
    console.log("Loterie object:", loterie);

    if (!loterie.deployTransaction) {
      console.error("Loterie object details:", loterie);
      throw new Error("Deployment transaction is undefined");
    }

    await loterie.deployTransaction.wait();
    console.log("Loterie déployé à l'adresse :", loterie.address);
  } catch (error) {
    console.error("Error during deployment:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error in main function:", error);
    process.exit(1);
  });
