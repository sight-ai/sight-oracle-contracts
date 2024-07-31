// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test, console, Vm } from "forge-std/Test.sol";
import "@sight-ai/contracts/Types.sol";
import { Oracle } from "@sight-ai/contracts/Oracle.sol";
import { CapsulatedValue, RequestBuilder } from "@sight-ai/contracts/RequestBuilder.sol";
import { ReencryptRequestBuilder } from "@sight-ai/contracts/ReencryptRequestBuilder.sol";
import { UseCaseExample } from "../src/UseCaseExample.sol";

contract UseCaseExampleTest is Test {
    UseCaseExample public example;
    Oracle public oracle;
    bytes32 requestId;

    function setUp() public {
        oracle = new Oracle();
        example = new UseCaseExample(address(oracle));
        vm.recordLogs();
        example.singleRequest();
        Vm.Log[] memory entries = vm.getRecordedLogs();
        RequestBuilder.Request memory req = abi.decode(entries[entries.length - 1].data, (RequestBuilder.Request)); // parse event params.
        requestId = req.id;
    }

    function test_makeComplicatedRequest() public {
        vm.recordLogs();
        example.makeComplicatedRequest();
        Vm.Log[] memory entries = vm.getRecordedLogs();
        RequestBuilder.Request memory req = abi.decode(entries[entries.length - 1].data, (RequestBuilder.Request)); // parse event params.
        bytes32 requestId_ = req.id;
        console.log("makeComplicatedRequest's id: %s", uint256(requestId_));
        CapsulatedValue[] memory results = new CapsulatedValue[](7);
        results[0] = CapsulatedValue(0, 129);
        results[1] = CapsulatedValue(1, 129);
        results[2] = CapsulatedValue(2, 129);
        results[3] = CapsulatedValue(3, 129);
        results[4] = CapsulatedValue(4, 129);
        results[5] = CapsulatedValue(5, 129);
        results[6] = CapsulatedValue(0, 128);
        oracle.callback(requestId_, results);
        assertEq(ebool.unwrap(example.myValue()), 0);
    }

    function test_singleRequest() public {
        console.log("singleRequest's id: %s", uint256(requestId));
        CapsulatedValue[] memory results = new CapsulatedValue[](1);
        results[0] = CapsulatedValue(0, 129);
        oracle.callback(requestId, results);
        assertEq(euint64.unwrap(example.myValue1()), 0);
    }

    function test_secondRequest() public {
        vm.recordLogs();
        example.secondRequest();
        Vm.Log[] memory entries = vm.getRecordedLogs();
        RequestBuilder.Request memory req = abi.decode(entries[entries.length - 1].data, (RequestBuilder.Request)); // parse event params.
        bytes32 requestId_ = req.id;
        console.log("secondRequest's id: %s", uint256(requestId_));
        CapsulatedValue[] memory results = new CapsulatedValue[](3);
        results[0] = CapsulatedValue(0, 129);
        results[1] = CapsulatedValue(1, 129);
        results[2] = CapsulatedValue(2, 129);
        oracle.callback(requestId_, results);
        assertEq(euint64.unwrap(example.myValue2()), 2);
    }
}
