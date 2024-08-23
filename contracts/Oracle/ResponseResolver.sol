// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ebool, euint64, eaddress, CapsulatedValue, Types } from "./Types.sol";

library ResponseResolver {
    function asBool(CapsulatedValue memory capsulatedValue) internal pure returns (bool) {
        require(capsulatedValue.valueType == Types.T_BOOL, "Invalid valueType for Bool");
        return (capsulatedValue.data % 2) == 1;
    }

    function asUint64(CapsulatedValue memory capsulatedValue) internal pure returns (uint64) {
        require(capsulatedValue.valueType == Types.T_UINT64, "Invalid valueType for Uint64");
        return uint64(capsulatedValue.data);
    }

    function asAddress(CapsulatedValue memory capsulatedValue) internal pure returns (address) {
        require(capsulatedValue.valueType == Types.T_ADDRESS, "Invalid valueType for address");
        return address(uint160(capsulatedValue.data));
    }

    function asEbool(CapsulatedValue memory capsulatedValue) internal pure returns (ebool) {
        require(capsulatedValue.valueType == Types.T_EBOOL, "Invalid valueType for Ebool");
        return ebool.wrap(capsulatedValue.data);
    }

    function asEuint64(CapsulatedValue memory capsulatedValue) internal pure returns (euint64) {
        require(capsulatedValue.valueType == Types.T_EUINT64, "Invalid valueType for Euint64");
        return euint64.wrap(capsulatedValue.data);
    }

    function asEaddress(CapsulatedValue memory capsulatedValue) internal pure returns (eaddress) {
        require(capsulatedValue.valueType == Types.T_EADDRESS, "Invalid valueType for Eaddress");
        return eaddress.wrap(capsulatedValue.data);
    }
}
