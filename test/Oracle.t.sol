// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test, console, Vm } from "forge-std/Test.sol";
import "../contracts/Oracle/Types.sol";
import { Oracle } from "../contracts/Oracle/Oracle.sol";
import { StorageACL } from "../contracts/Oracle/StorageACL.sol";
import { CapsulatedValue, Request } from "../contracts/Oracle/Types.sol";
import { RequestBuilder } from "../contracts/Oracle/RequestBuilder.sol";
import { CapsulatedValueResolver, ResponseResolver } from "../contracts/Oracle/CapsulatedValueResolver.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

using CapsulatedValueResolver for euint64;

contract UseCaseExample {
    using RequestBuilder for Request;

    address public oracleAddress;
    euint64 public myValue;

    constructor(address _oracleAddress) {
        oracleAddress = _oracleAddress;
    }

    function singleRequest() public returns (bytes32) {
        Request memory r = RequestBuilder.newRequest(
            msg.sender,
            1, // Adjust this length as needed for gas-efficiency
            address(this),
            this.callback.selector,
            msg.data
        );
        /* op result =  */ r.rand();
        return Oracle(oracleAddress).send(r);
    }

    function callback(bytes32 /* requestId */, CapsulatedValue[] memory results) public {
        myValue = ResponseResolver.asEuint64(results[results.length - 1]);
    }

    fallback() external payable {}
    receive() external payable {}
}

contract OracleTest is Test {
    UseCaseExample public example;
    Oracle public oracle;
    bytes32 requestId;

    function setUp() public {
        oracle = new Oracle();
        StorageACL storageACL = new StorageACL();
        storageACL.transferOwnership(address(oracle));
        address[] memory callers = new address[](1);
        callers[0] = address(this);
        oracle.addCallers(callers);
        oracle.setStorageACL(address(storageACL));
        example = new UseCaseExample(address(oracle));
    }

    function test_singleRequest() public {
        Operation[] memory ops = new Operation[](0);
        Request memory fake_req = Request(
            address(this),
            ops,
            1,
            address(example),
            example.callback.selector,
            bytes("")
        );
        vm.expectEmit(false, true, true, false, address(oracle));
        emit Oracle.RequestSent("", fake_req);
        vm.recordLogs();
        requestId = example.singleRequest();
        console.log("singleRequest's id: %s", Strings.toHexString(uint256(requestId), 32));
        CapsulatedValue[] memory results = new CapsulatedValue[](1);
        results[0] = CapsulatedValue(abi.encode(0), 129);
        oracle.callback(requestId, results);
        assertEq(abi.decode(example.myValue().asCapsulatedValue().data, (uint256)), 0);
    }
}
