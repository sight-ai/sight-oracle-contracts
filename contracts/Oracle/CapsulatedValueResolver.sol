// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Types, CapsulatedValue, op, ebool, euint64, eaddress } from "./Types.sol";

library ResponseResolver {
    function asBool(CapsulatedValue memory capsulatedValue) internal pure returns (bool) {
        require(capsulatedValue.valueType == Types.T_BOOL, "Invalid valueType for Bool");
        return abi.decode(capsulatedValue.data, (bool));
    }

    function asUint64(CapsulatedValue memory capsulatedValue) internal pure returns (uint64) {
        require(capsulatedValue.valueType == Types.T_UINT64, "Invalid valueType for Uint64");
        return abi.decode(capsulatedValue.data, (uint64));
    }

    function asAddress(CapsulatedValue memory capsulatedValue) internal pure returns (address) {
        require(capsulatedValue.valueType == Types.T_ADDRESS, "Invalid valueType for address");
        return abi.decode(capsulatedValue.data, (address));
    }

    function asEbool(CapsulatedValue memory capsulatedValue) internal pure returns (ebool) {
        require(capsulatedValue.valueType == Types.T_EBOOL, "Invalid valueType for Ebool");
        return ebool.wrap(abi.decode(capsulatedValue.data, (bytes32)));
    }

    function asEuint64(CapsulatedValue memory capsulatedValue) internal pure returns (euint64) {
        require(capsulatedValue.valueType == Types.T_EUINT64, "Invalid valueType for Euint64");
        return euint64.wrap(abi.decode(capsulatedValue.data, (bytes32)));
    }

    function asEaddress(CapsulatedValue memory capsulatedValue) internal pure returns (eaddress) {
        require(capsulatedValue.valueType == Types.T_EADDRESS, "Invalid valueType for Eaddress");
        return eaddress.wrap(abi.decode(capsulatedValue.data, (bytes32)));
    }

    function asBytes32(CapsulatedValue memory capsulatedValue) internal pure returns (bytes32) {
        require(
            capsulatedValue.valueType == Types.T_EBOOL ||
                capsulatedValue.valueType == Types.T_EUINT64 ||
                capsulatedValue.valueType == Types.T_EADDRESS,
            "Invalid valueType for Bytes32"
        );
        return abi.decode(capsulatedValue.data, (bytes32));
    }
}

library CapsulatedValueResolver {
    function asCapsulatedValue(op op_) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(abi.encode(op.unwrap(op_)), Types.T_UINT256);
    }

    function asCapsulatedValue(bool b) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(abi.encode(b), Types.T_BOOL);
    }

    function asCapsulatedValue(uint64 u64) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(abi.encode(u64), Types.T_UINT64);
    }

    function asCapsulatedValue(address addr) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(abi.encode(addr), Types.T_ADDRESS);
    }

    function asCapsulatedValue(ebool eb) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(abi.encode(ebool.unwrap(eb)), Types.T_EBOOL);
    }

    function asCapsulatedValue(euint64 eu64) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(abi.encode(euint64.unwrap(eu64)), Types.T_EUINT64);
    }

    function asCapsulatedValue(eaddress eaddr) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(abi.encode(eaddress.unwrap(eaddr)), Types.T_EADDRESS);
    }

    function asEbool(bytes32 key) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(abi.encode(key), Types.T_EBOOL);
    }

    function asEuint64(bytes32 key) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(abi.encode(key), Types.T_EUINT64);
    }

    function asEaddress(bytes32 key) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(abi.encode(key), Types.T_EADDRESS);
    }

    function asEboolBytes(bytes memory data) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(data, Types.T_EBOOL_BYTES);
    }

    function asEuint64Bytes(bytes memory data) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(data, Types.T_EUINT64_BYTES);
    }

    function asEaddressBytes(bytes memory data) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(data, Types.T_EADDRESS_BYTES);
    }
}
