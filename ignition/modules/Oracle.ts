import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

import { ORACLE_ADDR_OP_SEPOLIA } from "../../contracts/Oracle/constants/OracleAddresses";

const OracleModule = buildModule("OracleModule", (m) => {
  const Oracle = m.contract("Oracle", [], {});
  return { Oracle };
});

export default OracleModule;
