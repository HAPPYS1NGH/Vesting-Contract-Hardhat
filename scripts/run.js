const { Contract } = require("hardhat/internal/hardhat-network/stack-traces/model");

async function main() {
    const [admin1 , admin2] = await hre.ethers.getSigners();
    console.log("--------------Starting----------------");
    console.log("Admin1 "+ admin1.address + "\nAdmin2 "+ admin2.address);
    console.log("--------------Contract----------------");

    const Vesting = await hre.ethers.getContractFactory("Vesting");
    const vesting = await Vesting.deploy();
    const d = new Date();
  
    await vesting.deployed();
  
    console.log(
      `Vesting Contrat deployed to ${vesting.address}`
    );

    await vesting.registerOrganisation("Happy", "HP");
    await vesting.connect(admin2).registerOrganisation("Sad", "ST");
    console.log("--------------Organisation----------------");
    const Organisations = await vesting.getOrganisations();
    Organisations.map((el , i)=>{
        console.log(`Organisation ${i+1} is ${el} `)
    })

    const Organisation1 = Organisations[0];
    console.log("--------------Org1----------------");
    console.log(Organisation1);

    console.log("--------------Adding Stakeholders----------------");
    await vesting.connect(admin1).addStakeHolders(Organisation1.contractAddress , "founders" , admin1.address ,  Date.now() +1000 , 10);


    console.log("--------------Fetching Stakeholders----------------");
    const holders = await vesting.getStakeHolders(Organisation1.contractAddress);
    console.log(holders);
  }

  console.log("--------------Token Balances----------------");


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });