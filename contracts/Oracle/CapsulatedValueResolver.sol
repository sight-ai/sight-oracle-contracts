// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Types, CapsulatedValue, ebool, euint64, eaddress } from "./Types.sol";

library CapsulatedValueResolver {
    function asCapsulatedValue(ebool eb) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(ebool.unwrap(eb), Types.T_EBOOL);
    }

    function asCapsulatedValue(euint64 eu64) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(euint64.unwrap(eu64), Types.T_EUINT64);
    }

    function asCapsulatedValue(eaddress eaddr) internal pure returns (CapsulatedValue memory) {
        return CapsulatedValue(eaddress.unwrap(eaddr), Types.T_EADDRESS);
    }
}
