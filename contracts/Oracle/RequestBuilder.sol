// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Types.sol";

type op is uint256;

library Opcode {
    // Request Context
    uint8 internal constant get_euint64 = 0;
    uint8 internal constant get_ebool = 1;

    // Random Encrypted Value
    uint8 internal constant rand_euint64 = 2;

    // Encrypted Arithmetic Operations
    uint8 internal constant add_euint64_euint64 = 3;
    uint8 internal constant add_euint64_uint64 = 4;
    uint8 internal constant sub_euint64_euint64 = 5;
    uint8 internal constant sub_euint64_uint64 = 6;
    uint8 internal constant sub_uint64_euint64 = 7;

    uint8 internal constant mul = 8;
    uint8 internal constant div_euint64_euint64 = 9; // division
    uint8 internal constant div_euint64_uint64 = 10; // division
    uint8 internal constant div_uint64_euint64 = 11; // division

    // Encrypted Bitwise Operations
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

    // Encrypted Value Compare
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

    uint8 internal constant shl = 44; // shift left TBD
    uint8 internal constant shr = 45; // shift right TBD
    uint8 internal constant rotl = 46; // rotate left TBD
    uint8 internal constant rotr = 47; // rotate right TBD

    uint8 internal constant select = 48; // select(ebool, value1, value2)

    // Decryption
    uint8 internal constant decrypt_ebool = 49;
    uint8 internal constant decrypt_euint64 = decrypt_ebool + 1;
}

library RequestBuilder {
    struct Operation {
        uint8 opcode;
        uint256[] operands; // Indices of the operands or an encrypted value.
        uint64 value; // Direct value if applicable
    }

    struct Request {
        bytes32 id;
        address requester;
        Operation[] ops;
        uint256 opsCursor;
        address callbackAddr;
        bytes4 callbackFunc;
        bytes payload;
    }

    function newRequest(
        address requester,
        uint256 opsLength,
        address callbackAddr,
        bytes4 callbackFunc,
        bytes memory payload
    ) internal pure returns (Request memory) {
        Operation[] memory ops = new Operation[](opsLength);
        Request memory r = Request({
            id: bytes32(0),
            requester: requester,
            ops: ops,
            opsCursor: 0,
            callbackAddr: callbackAddr,
            callbackFunc: callbackFunc,
            payload: payload
        });
        return r;
    }

    function complete(Request memory r) internal view {
        // Serialize the operations array
        bytes memory operationsData;
        for (uint256 i = 0; i < r.ops.length; i++) {
            operationsData = abi.encodePacked(operationsData, r.ops[i].opcode, r.ops[i].operands, r.ops[i].value);
        }

        // Generate a unique ID based on requester address, serialized operations, and block properties
        r.id = keccak256(abi.encodePacked(r.requester, operationsData, block.timestamp, block.number));
    }

    // load an encrypted value into the execution context
    function getEbool(Request memory r, ebool input) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.get_ebool, operands: new uint256[](1), value: 0 });
        _op.operands[0] = ebool.unwrap(input);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    function getEuint64(Request memory r, euint64 input) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.get_euint64, operands: new uint256[](1), value: 0 });
        _op.operands[0] = euint64.unwrap(input);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // request a random euint64
    function rand(Request memory r) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.rand_euint64,
            operands: new uint256[](0), // Create an empty array
            value: 0
        });

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // add euint64 with euint64
    function add(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.add_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // add euint64 with uint64
    function add(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.add_euint64_uint64,
            operands: new uint256[](1),
            value: plaintextValue
        });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // sub euint64 with euint64
    function sub(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.sub_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // sub euint64 with uint64
    function sub(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.sub_euint64_uint64,
            operands: new uint256[](1),
            value: plaintextValue
        });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // sub uint64 with euint64
    function sub(Request memory r, uint64 plaintextValue, op index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.sub_uint64_euint64,
            operands: new uint256[](1),
            value: plaintextValue
        });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // mul euint64 with euint64
    function mul(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.mul, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // mul euint64 with uint64
    function mul(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.mul, operands: new uint256[](1), value: plaintextValue });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // div euint64 with euint64
    function div(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.div_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // div euint64 with uint64
    function div(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.div_euint64_uint64,
            operands: new uint256[](1),
            value: plaintextValue
        });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // div uint64 with euint64
    function div(Request memory r, uint64 plaintextValue, op index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.div_uint64_euint64,
            operands: new uint256[](1),
            value: plaintextValue
        });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // and euint64 with euint64
    function and(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.and_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // and euint64 with uint64
    function and(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.and_euint64_uint64,
            operands: new uint256[](1),
            value: plaintextValue
        });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // or euint64 with euint64
    function or(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.or_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // or euint64 with uint64
    function or(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.or_euint64_uint64,
            operands: new uint256[](1),
            value: plaintextValue
        });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // xor euint64 with euint64
    function xor(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.xor_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // xor euint64 with uint64
    function xor(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.xor_euint64_uint64,
            operands: new uint256[](1),
            value: plaintextValue
        });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // rem euint64 with euint64
    function rem(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.rem_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // rem euint64 with uint64
    function rem(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.rem_euint64_uint64,
            operands: new uint256[](1),
            value: plaintextValue
        });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // rem uint64 with euint64
    function rem(Request memory r, uint64 plaintextValue, op index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.rem_uint64_euint64,
            operands: new uint256[](1),
            value: plaintextValue
        });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // eq euint64 with euint64
    function eq(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.eq_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // eq euint64 with uint64
    function eq(Request memory r, op leftIndex, uint64 rightValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.eq_euint64_uint64,
            operands: new uint256[](2),
            value: rightValue
        });
        _op.operands[0] = op.unwrap(leftIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // eq uint64 with euint64
    function eq(Request memory r, uint64 leftValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.eq_uint64_euint64,
            operands: new uint256[](2),
            value: leftValue
        });
        _op.operands[0] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // ne euint64 with euint64
    function ne(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.ne_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // ne euint64 with uint64
    function ne(Request memory r, op leftIndex, uint64 rightValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.ne_euint64_uint64,
            operands: new uint256[](2),
            value: rightValue
        });
        _op.operands[0] = op.unwrap(leftIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // ne uint64 with euint64
    function ne(Request memory r, uint64 leftValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.ne_uint64_euint64,
            operands: new uint256[](2),
            value: leftValue
        });
        _op.operands[0] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // ge euint64 with euint64
    function ge(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.ge_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // ge euint64 with uint64
    function ge(Request memory r, op leftIndex, uint64 rightValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.ge_euint64_uint64,
            operands: new uint256[](2),
            value: rightValue
        });
        _op.operands[0] = op.unwrap(leftIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // ge uint64 with euint64
    function ge(Request memory r, uint64 leftValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.ge_uint64_euint64,
            operands: new uint256[](2),
            value: leftValue
        });
        _op.operands[0] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // gt euint64 with euint64
    function gt(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.gt_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // gt euint64 with uint64
    function gt(Request memory r, op leftIndex, uint64 rightValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.gt_euint64_uint64,
            operands: new uint256[](2),
            value: rightValue
        });
        _op.operands[0] = op.unwrap(leftIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // gt uint64 with euint64
    function gt(Request memory r, uint64 leftValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.gt_uint64_euint64,
            operands: new uint256[](2),
            value: leftValue
        });
        _op.operands[0] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // le euint64 with euint64
    function le(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.le_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // le euint64 with uint64
    function le(Request memory r, op leftIndex, uint64 rightValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.le_euint64_uint64,
            operands: new uint256[](2),
            value: rightValue
        });
        _op.operands[0] = op.unwrap(leftIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // le uint64 with euint64
    function le(Request memory r, uint64 leftValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.le_uint64_euint64,
            operands: new uint256[](2),
            value: leftValue
        });
        _op.operands[0] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // lt euint64 with euint64
    function lt(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.lt_euint64_euint64, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // lt euint64 with uint64
    function lt(Request memory r, op leftIndex, uint64 rightValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.lt_euint64_uint64,
            operands: new uint256[](2),
            value: rightValue
        });
        _op.operands[0] = op.unwrap(leftIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // lt uint64 with euint64
    function lt(Request memory r, uint64 leftValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.lt_uint64_euint64,
            operands: new uint256[](2),
            value: leftValue
        });
        _op.operands[0] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // min euint64 with euint64
    function min(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.min, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // max euint64 with euint64
    function max(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.max, operands: new uint256[](2), value: 0 });
        _op.operands[0] = op.unwrap(leftIndex);
        _op.operands[1] = op.unwrap(rightIndex);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // shl euint64
    function shl(Request memory r, op index, uint64 shiftValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.shl, operands: new uint256[](1), value: shiftValue });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // shr euint64
    function shr(Request memory r, op index, uint64 shiftValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.shr, operands: new uint256[](1), value: shiftValue });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // rotl euint64
    function rotl(Request memory r, op index, uint64 rotateValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.rotl, operands: new uint256[](1), value: rotateValue });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // rotr euint64
    function rotr(Request memory r, op index, uint64 rotateValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.rotr, operands: new uint256[](1), value: rotateValue });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // select(ebool, value1, value2)
    function select(Request memory r, op eboolIndex, op value1Index, op value2Index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.select, operands: new uint256[](3), value: 0 });
        _op.operands[0] = op.unwrap(eboolIndex);
        _op.operands[1] = op.unwrap(value1Index);
        _op.operands[2] = op.unwrap(value2Index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // decrypt euint64
    function decryptEuint64(Request memory r, op index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.decrypt_euint64, operands: new uint256[](1), value: 0 });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // decrypt ebool
    function decryptEbool(Request memory r, op index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.decrypt_ebool, operands: new uint256[](1), value: 0 });
        _op.operands[0] = op.unwrap(index);

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }
}
