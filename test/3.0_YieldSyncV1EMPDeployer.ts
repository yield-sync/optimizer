const { ethers } = require("hardhat");


import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";


describe("[3.0] YieldSyncV1EMPDeployer.sol - Setup", async () => {
	let mockYieldSyncGovernance: Contract;
	let yieldSyncV1EMPRegistry: Contract;
	let yieldSyncV1EMPDeployer: Contract;


	beforeEach("[beforeEach] Set up contracts..", async () => {
		/**
		* This beforeEach process does the following:
		* 1) Deploy a registry
		* 2) deploys an EMP Deployer and registers it on the registry
		*/
		const [OWNER, MANAGER, TREASURY] = await ethers.getSigners();

		const MockYieldSyncGovernance: ContractFactory = await ethers.getContractFactory("MockYieldSyncGovernance");
		const YieldSyncV1EMPRegistry: ContractFactory = await ethers.getContractFactory("YieldSyncV1EMPRegistry");
		const YieldSyncV1EMPDeployer: ContractFactory = await ethers.getContractFactory("YieldSyncV1EMPDeployer");

		mockYieldSyncGovernance = await (await MockYieldSyncGovernance.deploy()).deployed();
		yieldSyncV1EMPRegistry = await (await YieldSyncV1EMPRegistry.deploy(mockYieldSyncGovernance.address)).deployed();
		yieldSyncV1EMPDeployer = await (await YieldSyncV1EMPDeployer.deploy(yieldSyncV1EMPRegistry.address)).deployed();

		// Set Treasury
		await expect(mockYieldSyncGovernance.payToUpdate(TREASURY.address)).to.not.be.reverted;

		// Set the EMP Deployer on registry
		await expect(yieldSyncV1EMPRegistry.yieldSyncV1EMPDeployerUpdate(yieldSyncV1EMPDeployer.address)).to.not.be.reverted;
	});

	describe("Setup process", async () => {
		it("Should initialize the contract correctly", async () => {
			// Deploy an EMP
			await expect(yieldSyncV1EMPDeployer.deployYieldSyncV1EMP("EMP Name", "EMP")).to.be.not.reverted;

			// Verify that a EMP Strategy has been registered
			expect(await yieldSyncV1EMPRegistry.yieldSyncV1EMPId_yieldSyncV1EMP(1)).to.be.not.equal(
				ethers.constants.AddressZero
			);
		})
	});
});
