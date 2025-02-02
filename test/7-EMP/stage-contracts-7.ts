import { PERCENT } from "../../const";
import { deployContract, deployEMP, deployStrategies } from "../../util/UtilEMP";
import stageContracts, { StageContracts6 } from "../6-EMPDeployer/stage-contracts-6";


export type StageContracts7 = StageContracts6 & {
	eMPs: TestEMP[],
	strategies: TestStrategy[],
};


export default async (): Promise<StageContracts7> => {
	const {
		addressArrayUtility,
		governance,
		eTHValueProvider,
		eTHValueProviderC,
		eMPDeployer,
		eMPUtility,
		registry,
		strategyDeployer,
		strategyUtility,
		eRC20A,
		eRC20B,
		eRC20C,
		eRC20D,
		owner,
		manager,
		treasury,
		badActor,
	}: StageContracts6 = await stageContracts();

	/**
	* EMP Strategies
	*/
	const strategies: TestStrategy[] = await deployStrategies(
		registry,
		strategyDeployer,
		[
			{
				strategyUtilizedERC20: [eRC20A.address, eRC20B.address],
				strategyUtilization: [[true, true, PERCENT.FIFTY], [true, true, PERCENT.FIFTY]],
			},
			{
				strategyUtilizedERC20: [eRC20C.address],
				strategyUtilization: [[true, true, PERCENT.HUNDRED]],
			},
		],
	);

	const eRC20Handler = await deployContract("Holder", [strategies[0].contract.address]);
	const eRC20Handler2 = await deployContract("Holder", [strategies[1].contract.address]);

	await strategies[0].contract.iERC20HandlerUpdate(eRC20Handler.address);
	await strategies[1].contract.iERC20HandlerUpdate(eRC20Handler2.address);

	await strategies[0].contract.utilizedERC20DepositOpenUpdate(true);
	await strategies[0].contract.utilizedERC20WithdrawOpenUpdate(true);

	await strategies[1].contract.utilizedERC20DepositOpenUpdate(true);
	await strategies[1].contract.utilizedERC20WithdrawOpenUpdate(true);

	/**
	* EMP
	*/
	const eMPs: TestEMP[] = await deployEMP(
		manager.address,
		registry,
		eMPDeployer,
		eMPUtility,
		[
			{
				name: "EMP 1",
				ticker: "EMP1",
				utilizedEMPStrategyUpdate: [strategies[0].contract.address, strategies[1].contract.address],
				utilizedEMPStrategyAllocationUpdate: [PERCENT.FIFTY, PERCENT.FIFTY],
			},
			{
				name: "EMP 2",
				ticker: "EMP2",
				utilizedEMPStrategyUpdate: [strategies[0].contract.address, strategies[1].contract.address],
				utilizedEMPStrategyAllocationUpdate: [PERCENT.SEVENTY_FIVE, PERCENT.TWENTY_FIVE],
			},
			{
				name: "EMP 3",
				ticker: "EMP3",
				utilizedEMPStrategyUpdate: [],
				utilizedEMPStrategyAllocationUpdate: [],
			},
		]
	);

	return {
		addressArrayUtility,
		governance,
		eTHValueProvider,
		eTHValueProviderC,
		eMPDeployer,
		eMPs,
		eMPUtility,
		manager,
		eRC20A,
		eRC20B,
		eRC20C,
		eRC20D,
		badActor,
		owner,
		registry,
		strategies,
		strategyDeployer,
		strategyUtility,
		treasury,
	};
};
