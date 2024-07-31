import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OracleModule = buildModule("OracleModule", (m) => {
  const Oracle = m.contract("Oracle", [], {});
  return { Oracle };
});

export default OracleModule;
