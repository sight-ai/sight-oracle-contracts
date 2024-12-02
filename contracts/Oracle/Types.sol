// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

type ebool is bytes32;
type euint4 is bytes32;
type euint8 is bytes32;
type euint16 is bytes32;
type euint32 is bytes32;
type euint64 is bytes32;
type eaddress is bytes32;

type op is uint256;

enum EType {
    Zero,
    Ebool,
    Euint64,
    Eaddress
}

struct CapsulatedValue {
    bytes data;
    uint8 valueType;
}

struct Operation {
    uint8 opcode;
    CapsulatedValue[] operands;
}

struct Request {
    address requester;
    Operation[] ops;
    uint256 opsCursor;
    address callbackAddr;
    bytes4 callbackFunc;
    bytes payload;
}

struct ReencryptRequest {
    address requester;
    CapsulatedValue target;
    bytes32 publicKey;
    bytes signature;
    address callbackAddr;
    bytes4 callbackFunc;
}

struct SaveCiphertextRequest {
    address requester;
    bytes ciphertext;
    uint8 ciphertextType;
    address callbackAddr;
    bytes4 callbackFunc;
}

library Opcode {
    // Encrypted_Op
    uint8 internal constant get_euint64 = 0;
    uint8 internal constant get_ebool = 1;
    uint8 internal constant rand_euint64 = 2;
    uint8 internal constant add_euint64_euint64 = 3;
    uint8 internal constant add_euint64_uint64 = 4;
    uint8 internal constant sub_euint64_euint64 = 5;
    uint8 internal constant sub_euint64_uint64 = 6;
    uint8 internal constant sub_uint64_euint64 = 7;

    uint8 internal constant mul = 8;
    uint8 internal constant div_euint64_euint64 = 9; // division
    uint8 internal constant div_euint64_uint64 = 10; // division
    uint8 internal constant div_uint64_euint64 = 11; // division
    uint8 internal constant and_euint64_euint64 = 12;
    uint8 internal constant and_euint64_uint64 = 13;
    uint8 internal constant and_uint64_euint64 = 14;
    uint8 internal constant or_euint64_euint64 = 15;
    uint8 internal constant or_euint64_uint64 = 16;
    uint8 internal constant or_uint64_euint64 = 17;
    uint8 internal constant xor_euint64_euint64 = 18;
    uint8 internal constant xor_euint64_uint64 = 19;
    uint8 internal constant xor_uint64_euint64 = 20;
    uint8 internal constant rem_euint64_euint64 = 21; // remainder
    uint8 internal constant rem_euint64_uint64 = 22; // remainder
    uint8 internal constant rem_uint64_euint64 = 23; // remainder

    // Encrypted Compare
    uint8 internal constant eq_euint64_euint64 = 24; // equal
    uint8 internal constant eq_euint64_uint64 = 25;
    uint8 internal constant eq_uint64_euint64 = 26;
    uint8 internal constant ne_euint64_euint64 = 27; // not equal
    uint8 internal constant ne_euint64_uint64 = 28;
    uint8 internal constant ne_uint64_euint64 = 29;
    uint8 internal constant ge_euint64_euint64 = 30; // greater or equal
    uint8 internal constant ge_euint64_uint64 = 31;
    uint8 internal constant ge_uint64_euint64 = 32;
    uint8 internal constant gt_euint64_euint64 = 33; // greater than
    uint8 internal constant gt_euint64_uint64 = 34;
    uint8 internal constant gt_uint64_euint64 = 35;
    uint8 internal constant le_euint64_euint64 = 36; // less or equal
    uint8 internal constant le_euint64_uint64 = 37;
    uint8 internal constant le_uint64_euint64 = 38;
    uint8 internal constant lt_euint64_euint64 = 39; // less than
    uint8 internal constant lt_euint64_uint64 = 40;
    uint8 internal constant lt_uint64_euint64 = 41;

    uint8 internal constant min = 42;
    uint8 internal constant max = 43;

    uint8 internal constant shl = 44; // shift left
    uint8 internal constant shr = 45; // shift right
    uint8 internal constant rotl = 46; // rotate left
    uint8 internal constant rotr = 47; // rotate right

    uint8 internal constant select = 48; // select(ebool, value1, value2)
    uint8 internal constant decrypt_ebool = 49;
    uint8 internal constant decrypt_euint64 = 50;
    uint8 internal constant decrypt_eaddress = 51;
    uint8 internal constant decrypt_ebool_async = 52;
    uint8 internal constant decrypt_euint64_async = 53;
    uint8 internal constant decrypt_eaddress_async = 54;

    uint8 internal constant min_euint64_uint64 = 55;
    uint8 internal constant max_euint64_uint64 = 56;

    uint8 internal constant rand_ebool = 57;
    uint8 internal constant get_eaddress = 58;

    uint8 internal constant eq = 59; // equal
    uint8 internal constant ne = 60; // not equal

    uint8 internal constant save_ebool_bytes = 61;
    uint8 internal constant save_euint64_bytes = 62;
    uint8 internal constant save_eaddress_bytes = 63;
}

library Types {
    uint8 internal constant T_BOOL = 1;
    uint8 internal constant T_UINT64 = T_BOOL + 1;
    uint8 internal constant T_ADDRESS = T_BOOL + 2;
    uint8 internal constant T_UINT256 = T_BOOL + 3;

    uint8 internal constant T_EBOOL = 128;
    uint8 internal constant T_EUINT64 = T_EBOOL + 1;
    uint8 internal constant T_EADDRESS = T_EBOOL + 2;
    uint8 internal constant T_EBOOL_BYTES = T_EBOOL + 3;
    uint8 internal constant T_EUINT64_BYTES = T_EBOOL + 4;
    uint8 internal constant T_EADDRESS_BYTES = T_EBOOL + 5;
}
