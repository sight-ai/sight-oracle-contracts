import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";

const UseCaseExampleModule = buildModule("UseCaseExampleModule", (m) => {

  const UseCaseExample = m.contract("UseCaseExample", [], {
  });

  return { UseCaseExample };
});

export default UseCaseExampleModule;
