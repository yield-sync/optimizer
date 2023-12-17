const { ethers } = require("hardhat");


import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";


const ERROR_STRATEGY_ALREADY_SET = "address(yieldSyncV1AMPStrategyInteractor) != address(0)";
const HUNDRED_PERCENT = ethers.utils.parseUnits('1', 18);


describe("[0.0] YieldSyncV1VaultDeployer.sol", async () => {
	let mockERC20: Contract;
	let strategyInteractorBlank: Contract;
	let yieldSyncV1AMPStrategy: Contract;

	beforeEach("[beforeEach] Set up contracts..", async () => {
		const [owner] = await ethers.getSigners();

		const MockERC20: ContractFactory = await ethers.getContractFactory("MockERC20");
		const StrategyInteractorBlank: ContractFactory = await ethers.getContractFactory("StrategyInteractorBlank");
		const YieldSyncV1AMPStrategy: ContractFactory = await ethers.getContractFactory("YieldSyncV1AMPStrategy");

		mockERC20 = await (await MockERC20.deploy()).deployed();
		strategyInteractorBlank = await (await StrategyInteractorBlank.deploy()).deployed();
		yieldSyncV1AMPStrategy = await (await YieldSyncV1AMPStrategy.deploy(owner.address, "Exampe", "EX")).deployed();
	});

	describe("initializeStrategy()", async () => {
		it(
			"[auth] Should revert when unauthorized msg.sender calls..",
			async () => {
				const [, addr1] = await ethers.getSigners();

				await expect(
					yieldSyncV1AMPStrategy.connect(addr1).initializeStrategy(
						strategyInteractorBlank.address,
						[mockERC20.address]
					)
				).to.be.rejected;
			}
		);

		it(
			"It should be able to set _strategy and _utilizedERC20..",
			async () => {
				await yieldSyncV1AMPStrategy.initializeStrategy(strategyInteractorBlank.address, [mockERC20.address], [HUNDRED_PERCENT]);

				expect(await yieldSyncV1AMPStrategy.yieldSyncV1AMPStrategyInteractor()).to.be.equal(
					strategyInteractorBlank.address
				);
				expect((await yieldSyncV1AMPStrategy.utilizedERC20()).length).to.be.equal(1);
				expect((await yieldSyncV1AMPStrategy.utilizedERC20())[0]).to.be.equal(mockERC20.address);
			}
		);

		it(
			"It should be able only be able to set once..",
			async () => {
				await yieldSyncV1AMPStrategy.initializeStrategy(strategyInteractorBlank.address, [mockERC20.address], [HUNDRED_PERCENT]);

				await expect(
					yieldSyncV1AMPStrategy.initializeStrategy(
						strategyInteractorBlank.address,
						[mockERC20.address],
						[HUNDRED_PERCENT]
					)
				).to.be.rejectedWith(ERROR_STRATEGY_ALREADY_SET);
			}
		);
	});

	describe("utilizedERC20Deposit()", async () => {
		it(
			"Should be able to deposit ERC20 into strategy interactor..",
			async () => {
				const [owner] = await ethers.getSigners();

				const depositAmount = ethers.utils.parseUnits("1", 18);

				// Initialize strategy with mock ERC20
				await yieldSyncV1AMPStrategy.initializeStrategy(
					strategyInteractorBlank.address,
					[mockERC20.address],
					[HUNDRED_PERCENT]
				);

				// Approve the StrategyInteractorBlank contract to spend tokens on behalf of owner
				await mockERC20.connect(owner).approve(strategyInteractorBlank.address, depositAmount);

				// Deposit ERC20 tokens into the strategy
				await expect(
					yieldSyncV1AMPStrategy.connect(owner).utilizedERC20Deposit([depositAmount])
				).to.not.be.reverted;

				expect(await mockERC20.balanceOf(strategyInteractorBlank.address)).to.be.equal(depositAmount);
			}
		);
	});
});
