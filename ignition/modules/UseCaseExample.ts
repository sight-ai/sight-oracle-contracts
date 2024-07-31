import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

import OracleModule from "./Oracle";

// not working, because hardhat not support `paths.sources` as string[],
// UseCaseExample.sol in src/ not compiled, use foundry to deploy it.

const UseCaseExampleModule = buildModule("UseCaseExampleModule", (m) => {
  const { Oracle } = m.useModule(OracleModule);
  const UseCaseExample = m.contract("UseCaseExample", [Oracle], {});

  return { UseCaseExample };
});

export default UseCaseExampleModule;
