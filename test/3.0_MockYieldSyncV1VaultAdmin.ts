type UpdateVaultProperty = [
	// voteAgainstRequired
	number,
	// voteForRequired
	number,
	// transferDelaySeconds
	number,
]


const { ethers } = require("hardhat");


import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";


describe("[3.0] MockAdmin.sol", async () => {
	let yieldSyncV1Vault: Contract;
	let yieldSyncV1VaultRegistry: Contract;
	let yieldSyncV1VaultFactory: Contract;
	let yieldSyncV1ATransferRequestProtocol: Contract;
	let signatureProtocol: Contract;
	let mockAdmin: Contract;
	let mockDapp: Contract;
	let mockERC20: Contract;
	let mockERC721: Contract;
	let mockYieldSyncGovernance: Contract;


	beforeEach("[beforeEach] Set up contracts..", async () => {
		const [owner, addr1, addr2] = await ethers.getSigners();

		/// Contract Factory
		const MockAdmin: ContractFactory = await ethers.getContractFactory("MockAdmin");
		const MockERC20: ContractFactory = await ethers.getContractFactory("MockERC20");
		const MockERC721: ContractFactory = await ethers.getContractFactory("MockERC721");
		const MockDapp: ContractFactory = await ethers.getContractFactory("MockDapp");
		const MockYieldSyncGovernance: ContractFactory = await ethers.getContractFactory("MockYieldSyncGovernance");

		const YieldSyncV1Vault: ContractFactory = await ethers.getContractFactory("YieldSyncV1Vault");
		const YieldSyncV1VaultFactory: ContractFactory = await ethers.getContractFactory("YieldSyncV1VaultFactory");
		const YieldSyncV1VaultRegistry: ContractFactory = await ethers.getContractFactory("YieldSyncV1VaultRegistry");
		const YieldSyncV1ASignatureProtocol: ContractFactory = await ethers.getContractFactory("YieldSyncV1ASignatureProtocol");
		const YieldSyncV1ATransferRequestProtocol: ContractFactory = await ethers.getContractFactory("YieldSyncV1ATransferRequestProtocol");


		/// Deploy
		// Mock
		mockDapp = await (await MockDapp.deploy()).deployed();
		mockAdmin = await (await MockAdmin.deploy()).deployed();
		mockERC20 = await (await MockERC20.deploy()).deployed();
		mockERC721 = await (await MockERC721.deploy()).deployed();

		// Expected
		mockYieldSyncGovernance = await (await MockYieldSyncGovernance.deploy()).deployed();
		yieldSyncV1VaultRegistry = await (await YieldSyncV1VaultRegistry.deploy()).deployed();

		// Deploy Factory
		yieldSyncV1VaultFactory = await (
			await YieldSyncV1VaultFactory.deploy(mockYieldSyncGovernance.address, yieldSyncV1VaultRegistry.address)
		).deployed();

		// Deploy Transfer Request Protocol
		yieldSyncV1ATransferRequestProtocol = await (
			await YieldSyncV1ATransferRequestProtocol.deploy(
				yieldSyncV1VaultRegistry.address
			)
		).deployed();

		// Deploy Signature Protocol
		signatureProtocol = await (
			await YieldSyncV1ASignatureProtocol.deploy(
				mockYieldSyncGovernance.address,
				yieldSyncV1VaultRegistry.address
			)
		).deployed();

		await signatureProtocol.yieldSyncV1Vault_signaturesRequiredUpdate(2);

		// Set YieldSyncV1Vault properties on TransferRequestProtocol.sol
		await yieldSyncV1ATransferRequestProtocol.yieldSyncV1Vault_yieldSyncV1VaultPropertyAdminUpdate(
			owner.address,
			[2, 2, 5] as UpdateVaultProperty
		);

		// Deploy a vault
		await yieldSyncV1VaultFactory.deployYieldSyncV1Vault(
			signatureProtocol.address,
			yieldSyncV1ATransferRequestProtocol.address,
			[owner.address],
			[addr1.address, addr2.address],
			{ value: 1 }
		);

		// Attach the deployed vault's address
		yieldSyncV1Vault = await YieldSyncV1Vault.attach(
			await yieldSyncV1VaultFactory.yieldSyncV1VaultId_yieldSyncV1Vault(0)
		);

		// Send ether to YieldSyncV1Vault contract
		await addr1.sendTransaction({
			to: yieldSyncV1Vault.address,
			value: ethers.utils.parseEther(".5")
		});

		// Send ERC20 to YieldSyncV1Vault contract
		await mockERC20.transfer(yieldSyncV1Vault.address, 50);

		// Send ERC721 to YieldSyncV1Vault contract
		await mockERC721.transferFrom(owner.address, yieldSyncV1Vault.address, 1);
	});

	/**
	 * @dev Restriction: DEFAULT_ADMIN_ROLE
	*/
	describe("Restriction: DEFAULT_ADMIN_ROLE", async () => {
		describe("adminAdd()", async () => {
			it("Should allow admin to add a contract-based admin..", async () => {
				await yieldSyncV1Vault.adminAdd(mockAdmin.address);
			});
		});

		/**
		 * @dev yieldSyncV1Vault_transferRequestId_transferRequestAdminDelete
		*/
		describe("yieldSyncV1Vault_transferRequestId_transferRequestAdminUpdatelatestForVoteTime()", async () => {
			it(
				"Should update the latestForVoteTime to ADD seconds..",
				async () => {
					const [, addr1, addr2] = await ethers.getSigners();

					await yieldSyncV1Vault.adminAdd(mockAdmin.address);

					await yieldSyncV1ATransferRequestProtocol.connect(addr1).yieldSyncV1Vault_transferRequestId_transferRequestCreate(
						yieldSyncV1Vault.address,
						false,
						false,
						addr2.address,
						ethers.constants.AddressZero,
						ethers.utils.parseEther(".5"),
						0
					);

					const beforeBlockTimestamp = BigInt((
						await yieldSyncV1ATransferRequestProtocol.yieldSyncV1Vault_transferRequestId_transferRequestPoll(
							yieldSyncV1Vault.address,
							0
						)
					).latestForVoteTime);

					await mockAdmin.yieldSyncV1Vault_transferRequestId_transferRequestPollUpdatelatestForVoteTime(
						yieldSyncV1ATransferRequestProtocol.address,
						yieldSyncV1Vault.address,
						0,
						true,
						4000
					);

					const afterBlockTimestamp = BigInt((
						await yieldSyncV1ATransferRequestProtocol.yieldSyncV1Vault_transferRequestId_transferRequestPoll(
							yieldSyncV1Vault.address,
							0
						)
					).latestForVoteTime);

					expect(BigInt(beforeBlockTimestamp + BigInt(4000))).to.be.equal(afterBlockTimestamp);
				}
			);
		});
	});
});
