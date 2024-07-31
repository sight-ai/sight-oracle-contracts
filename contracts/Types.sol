// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

type ebool is uint256;
type euint4 is uint256;
type euint8 is uint256;
type euint16 is uint256;
type euint32 is uint256;
type euint64 is uint256;
type eaddress is uint256;

struct CapsulatedValue {
    uint256 data;
    uint8 valueType;
}

library Types {
    uint8 internal constant T_BOOL = 0;
    uint8 internal constant T_UINT64 = T_BOOL + 1;

    uint8 internal constant T_EBOOL = 128;
    uint8 internal constant T_EUINT64 = T_EBOOL + 1;
}
