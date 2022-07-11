const Loan = artifacts.require("Loan");

module.exports =async function (deployer,accounts) {
  await deployer.deploy(Loan, 1000, 10, 100, accounts[1], accounts[2]);
};
