const {
  Contract,
} = require("hardhat/internal/hardhat-network/stack-traces/model");

async function main() {
  const [admin1, admin2, investor] = await hre.ethers.getSigners();
  console.log("--------------Starting----------------");
  console.log("Admin1 " + admin1.address + "\nAdmin2 " + admin2.address);
  console.log("--------------Contract----------------");

  const Vesting = await hre.ethers.getContractFactory("Vesting");
  const vesting = await Vesting.deploy();
  const OrganisationToken = await hre.ethers.getContractFactory(
    "OrganisationToken"
  );
  const d = new Date();
  await vesting.deployed();

  console.log(`Vesting Contrat deployed to ${vesting.address}`);
  const { UserRole } = await hre.ethers.getContractFactory(
    "Vesting",
    vesting.address
  );

  await vesting.registerOrganisation("Happy", "HP");
  await vesting.connect(admin2).registerOrganisation("Sad", "ST");
  console.log("--------------Organisation----------------");
  const Organisations = await vesting.getOrganisations();
  Organisations.map((el, i) => {
    console.log(`Organisation ${i + 1} is ${el} `);
  });

  const Organisation1 = Organisations[0];
  console.log("--------------Org1----------------");
  console.log(Organisation1);

  console.log("--------------Adding Stakeholders----------------");
  await vesting
    .connect(admin1)
    .addStakeHolders(
      0,
      admin1.address,
      parseInt(Date.now() / 1000),
      10,
      Organisation1.contractAddress
    );
  await vesting
    .connect(admin1)
    .addStakeHolders(
      1,
      investor.address,
      parseInt(Date.now() / 1000),
      100,
      Organisation1.contractAddress
    );

  console.log("--------------Fetching Stakeholders----------------");
  let holders = await vesting.getHolders(Organisation1.contractAddress, 2);
  console.log(holders);

  console.log("--------------Token Balances----------------");
  const Organisation1Token = await OrganisationToken.attach(
    Organisation1.contractAddress
  );
  let balance = await Organisation1Token.balanceOf(
    holders[0].stakeHolderAddress
  );
  console.log(balance + "----Balance----");

  console.log("--------------Whitelisting----------------");
  await vesting.whitelist(1, Organisation1.contractAddress);
  console.log("--------------Fetching Stakeholders----------------");
  holders = await vesting.getHolders(Organisation1.contractAddress, 1);
  console.log(holders);
  console.log("--------------Whitelisting Fetching----------------");
  const whitelisted = await vesting.getWhiteList(Organisation1.contractAddress);
  console.log(whitelisted);
  // setTimeout(async () => {
  //   vesting.mintTokens(Organisation1.contractAddress, 2, admin1.address, 5);
  //   console.log("-----------MINTING------------");
  //   balance = await Organisation1Token.balanceOf(holders[0].stakeHolderAddress);
  //   console.log("----Balance is " + balance + " ----");
  // }, 1000);

  console.log("-----------MINTING------------");
  await vesting
    .connect(investor)
    .mintTokens(Organisation1.contractAddress, 2, investor.address, 5);

  console.log("--------------Token Balances----------------");
  balance = await Organisation1Token.balanceOf(holders[0].stakeHolderAddress);
  console.log(balance + "----Balance----");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
