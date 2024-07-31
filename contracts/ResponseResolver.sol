// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Types.sol";

library ResponseResolver {
    function asBool(CapsulatedValue memory capsulatedValue) internal pure returns (bool) {
        require(capsulatedValue.valueType == Types.T_BOOL, "Invalid valueType for Bool");
        return capsulatedValue.data == 1;
    }

    function asUint64(CapsulatedValue memory encryptedValue) internal pure returns (uint64) {
        require(encryptedValue.valueType == Types.T_UINT64, "Invalid valueType for Uint64");
        return uint64(encryptedValue.data);
    }

    function asEbool(CapsulatedValue memory encryptedValue) internal pure returns (ebool) {
        require(encryptedValue.valueType == Types.T_EBOOL, "Invalid valueType for Ebool");
        return ebool.wrap(encryptedValue.data);
    }

    function asEuint64(CapsulatedValue memory encryptedValue) internal pure returns (euint64) {
        require(encryptedValue.valueType == Types.T_EUINT64, "Invalid valueType for Euint64");
        return euint64.wrap(encryptedValue.data);
    }
}
