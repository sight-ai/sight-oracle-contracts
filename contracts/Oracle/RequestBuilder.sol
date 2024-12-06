// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ebool, euint64, eaddress, op, Request, Operation, CapsulatedValue, Opcode, Types } from "./Types.sol";
import { CapsulatedValueResolver, ResponseResolver } from "./CapsulatedValueResolver.sol";

library RequestBuilder {
    using CapsulatedValueResolver for op;
    using CapsulatedValueResolver for bool;
    using CapsulatedValueResolver for uint64;
    using CapsulatedValueResolver for address;
    using CapsulatedValueResolver for ebool;
    using CapsulatedValueResolver for euint64;
    using CapsulatedValueResolver for eaddress;
    using CapsulatedValueResolver for bytes;
    using CapsulatedValueResolver for bytes32;
    function newRequest(
        address requester,
        uint256 opsLength,
        address callbackAddr,
        bytes4 callbackFunc,
        bytes memory payload
    ) internal pure returns (Request memory) {
        Operation[] memory ops = new Operation[](opsLength);
        Request memory r = Request({
            requester: requester,
            ops: ops,
            opsCursor: 0,
            callbackAddr: callbackAddr,
            callbackFunc: callbackFunc,
            payload: payload
        });
        return r;
    }

    function newRequest(
        address requester,
        uint256 opsLength,
        address callbackAddr,
        bytes4 callbackFunc
    ) internal pure returns (Request memory) {
        Operation[] memory ops = new Operation[](opsLength);
        Request memory r = Request({
            requester: requester,
            ops: ops,
            opsCursor: 0,
            callbackAddr: callbackAddr,
            callbackFunc: callbackFunc,
            payload: ""
        });
        return r;
    }

    // load an encrypted value into the execution context
    function getEbool(Request memory r, ebool input) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.get_ebool, operands: new CapsulatedValue[](1) });
        _op.operands[0] = input.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    function getEaddress(Request memory r, eaddress input) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.get_eaddress, operands: new CapsulatedValue[](1) });
        _op.operands[0] = input.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    function getEuint64(Request memory r, euint64 input) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.get_euint64, operands: new CapsulatedValue[](1) });
        _op.operands[0] = input.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // request a random euint64
    function rand(Request memory r) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({
            opcode: Opcode.rand_euint64,
            operands: new CapsulatedValue[](0) // Create an empty array
        });

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // add euint64 with euint64
    function add(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.add_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // add euint64 with uint64
    function add(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.add_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = index.asCapsulatedValue();
        _op.operands[1] = plaintextValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // sub euint64 with euint64
    function sub(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.sub_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // sub euint64 with uint64
    function sub(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.sub_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = index.asCapsulatedValue();
        _op.operands[1] = plaintextValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // sub uint64 with euint64
    function sub(Request memory r, uint64 plaintextValue, op index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.sub_uint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = plaintextValue.asCapsulatedValue();
        _op.operands[1] = index.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // mul euint64 with euint64
    function mul(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.mul, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // mul euint64 with uint64
    function mul(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.mul, operands: new CapsulatedValue[](2) });
        _op.operands[0] = index.asCapsulatedValue();
        _op.operands[1] = plaintextValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // div euint64 with euint64
    function div(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.div_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // div euint64 with uint64
    function div(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.div_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = index.asCapsulatedValue();
        _op.operands[1] = plaintextValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // div uint64 with euint64
    function div(Request memory r, uint64 plaintextValue, op index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.div_uint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = plaintextValue.asCapsulatedValue();
        _op.operands[1] = index.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // and euint64 with euint64
    function and(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.and_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // and euint64 with uint64
    function and(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.and_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = index.asCapsulatedValue();
        _op.operands[1] = plaintextValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // or euint64 with euint64
    function or(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.or_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // or euint64 with uint64
    function or(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.or_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = index.asCapsulatedValue();
        _op.operands[1] = plaintextValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // xor euint64 with euint64
    function xor(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.xor_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // xor euint64 with uint64
    function xor(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.xor_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = index.asCapsulatedValue();
        _op.operands[1] = plaintextValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // rem euint64 with euint64
    function rem(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.rem_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // rem euint64 with uint64
    function rem(Request memory r, op index, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.rem_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = index.asCapsulatedValue();
        _op.operands[1] = plaintextValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // rem uint64 with euint64
    function rem(Request memory r, uint64 plaintextValue, op index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.rem_uint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = plaintextValue.asCapsulatedValue();
        _op.operands[1] = index.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // eq euint64 with euint64
    function eq(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.eq_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // eq euint64 with uint64
    function eq(Request memory r, op leftIndex, uint64 rightValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.eq_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // eq uint64 with euint64
    function eq(Request memory r, uint64 leftValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.eq_uint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftValue.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // ne euint64 with euint64
    function ne(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.ne_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // ne euint64 with uint64
    function ne(Request memory r, op leftIndex, uint64 rightValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.ne_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // ne uint64 with euint64
    function ne(Request memory r, uint64 leftValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.ne_uint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftValue.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // ge euint64 with euint64
    function ge(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.ge_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // ge euint64 with uint64
    function ge(Request memory r, op leftIndex, uint64 rightValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.ge_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // ge uint64 with euint64
    function ge(Request memory r, uint64 leftValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.ge_uint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftValue.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // gt euint64 with euint64
    function gt(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.gt_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // gt euint64 with uint64
    function gt(Request memory r, op leftIndex, uint64 rightValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.gt_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // gt uint64 with euint64
    function gt(Request memory r, uint64 leftValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.gt_uint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftValue.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // le euint64 with euint64
    function le(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.le_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // le euint64 with uint64
    function le(Request memory r, op leftIndex, uint64 rightValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.le_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // le uint64 with euint64
    function le(Request memory r, uint64 leftValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.le_uint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftValue.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // lt euint64 with euint64
    function lt(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.lt_euint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // lt euint64 with uint64
    function lt(Request memory r, op leftIndex, uint64 rightValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.lt_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // lt uint64 with euint64
    function lt(Request memory r, uint64 leftValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.lt_uint64_euint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftValue.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // min euint64 with euint64
    function min(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.min, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // min euint64 with uint64
    function min(Request memory r, op leftIndex, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.min_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = plaintextValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // min uint64 with euint64
    function min(Request memory r, uint64 plaintextValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.min_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = plaintextValue.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // max euint64 with euint64
    function max(Request memory r, op leftIndex, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.max, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // max euint64 with uint64
    function max(Request memory r, op leftIndex, uint64 plaintextValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.max_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = leftIndex.asCapsulatedValue();
        _op.operands[1] = plaintextValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // max uint64 with euint64
    function max(Request memory r, uint64 plaintextValue, op rightIndex) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.max_euint64_uint64, operands: new CapsulatedValue[](2) });
        _op.operands[0] = plaintextValue.asCapsulatedValue();
        _op.operands[1] = rightIndex.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // shl euint64
    function shl(Request memory r, op index, uint64 shiftValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.shl, operands: new CapsulatedValue[](2) });
        _op.operands[0] = index.asCapsulatedValue();
        _op.operands[1] = shiftValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // shr euint64
    function shr(Request memory r, op index, uint64 shiftValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.shr, operands: new CapsulatedValue[](2) });
        _op.operands[0] = index.asCapsulatedValue();
        _op.operands[1] = shiftValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // rotl euint64
    function rotl(Request memory r, op index, uint64 rotateValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.rotl, operands: new CapsulatedValue[](2) });
        _op.operands[0] = index.asCapsulatedValue();
        _op.operands[1] = rotateValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // rotr euint64
    function rotr(Request memory r, op index, uint64 rotateValue) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.rotr, operands: new CapsulatedValue[](2) });
        _op.operands[0] = index.asCapsulatedValue();
        _op.operands[1] = rotateValue.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // select(ebool, value1, value2)
    function select(Request memory r, op eboolIndex, op value1Index, op value2Index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.select, operands: new CapsulatedValue[](3) });
        _op.operands[0] = eboolIndex.asCapsulatedValue();
        _op.operands[1] = value1Index.asCapsulatedValue();
        _op.operands[2] = value2Index.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // decrypt euint64
    function decryptEuint64(Request memory r, op index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.decrypt_euint64, operands: new CapsulatedValue[](1) });
        _op.operands[0] = index.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // decrypt ebool
    function decryptEbool(Request memory r, op index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.decrypt_ebool, operands: new CapsulatedValue[](1) });
        _op.operands[0] = index.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // decrypt eaddress
    function decryptEaddress(Request memory r, op index) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.decrypt_eaddress, operands: new CapsulatedValue[](1) });
        _op.operands[0] = index.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // decrypt euint64 async
    function decryptEuint64Async(Request memory r, op index) internal pure returns (op) {
        Operation memory _op = Operation({ opcode: Opcode.decrypt_euint64_async, operands: new CapsulatedValue[](1) });
        _op.operands[0] = index.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // decrypt ebool async
    function decryptEboolAsync(Request memory r, op index) internal pure returns (op) {
        Operation memory _op = Operation({ opcode: Opcode.decrypt_ebool_async, operands: new CapsulatedValue[](1) });
        _op.operands[0] = index.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // decrypt eaddress async
    function decryptEaddressAsync(Request memory r, op index) internal pure returns (op) {
        Operation memory _op = Operation({ opcode: Opcode.decrypt_eaddress_async, operands: new CapsulatedValue[](1) });
        _op.operands[0] = index.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // save euint64 bytes
    function saveEuint64Bytes(Request memory r, bytes memory euint64Bytes) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.save_euint64_bytes, operands: new CapsulatedValue[](1) });
        _op.operands[0] = euint64Bytes.asEuint64Bytes();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // save ebool bytes
    function saveEboolBytes(Request memory r, bytes memory eboolBytes) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.save_ebool_bytes, operands: new CapsulatedValue[](1) });
        _op.operands[0] = eboolBytes.asEboolBytes();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // save eaddress bytes
    function saveEaddressBytes(Request memory r, bytes memory eaddressBytes) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.save_eaddress_bytes, operands: new CapsulatedValue[](1) });
        _op.operands[0] = eaddressBytes.asEaddressBytes();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }

    // reencrypt(ebool_idx, value1, value2)
    function reencrypt(
        Request memory r,
        op eIndex,
        bytes32 publicKey,
        bytes memory signature
    ) internal pure returns (op) {
        require(r.opsCursor < r.ops.length, "Operations array is full");
        Operation memory _op = Operation({ opcode: Opcode.reencrypt, operands: new CapsulatedValue[](3) });
        _op.operands[0] = eIndex.asCapsulatedValue();
        _op.operands[1] = publicKey.asCapsulatedValue();
        _op.operands[2] = signature.asCapsulatedValue();

        r.ops[r.opsCursor] = _op;
        r.opsCursor += 1;

        return op.wrap(r.opsCursor - 1);
    }
}
