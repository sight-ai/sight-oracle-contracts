// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test, console, Vm } from "forge-std/Test.sol";
import "../contracts/Oracle/Types.sol";
import { Oracle } from "../contracts/Oracle/Oracle.sol";
import { CapsulatedValue, RequestBuilder } from "../contracts/Oracle/RequestBuilder.sol";
import { ResponseResolver } from "../contracts/Oracle/ResponseResolver.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

contract UseCaseExample {
    using RequestBuilder for RequestBuilder.Request;

    address public oracleAddress;
    euint64 public myValue;

    constructor(address _oracleAddress) {
        oracleAddress = _oracleAddress;
    }

    function singleRequest() public {
        RequestBuilder.Request memory r = RequestBuilder.newRequest(
            msg.sender,
            1, // Adjust this length as needed for gas-efficiency
            address(this),
            this.callback.selector,
            msg.data
        );
        /* op result =  */ r.rand();
        r.complete();
        Oracle(oracleAddress).send(r);
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
        example = new UseCaseExample(address(oracle));
    }

    function test_singleRequest() public {
        RequestBuilder.Operation[] memory ops = new RequestBuilder.Operation[](0);
        RequestBuilder.Request memory fake_req = RequestBuilder.Request(
            bytes32(""),
            address(this),
            ops,
            1,
            address(example),
            example.callback.selector,
            bytes("")
        );
        vm.expectEmit(true, true, true, false, address(oracle));
        emit Oracle.RequestSent(fake_req);
        vm.recordLogs();
        example.singleRequest();
        Vm.Log[] memory entries = vm.getRecordedLogs();
        RequestBuilder.Request memory req = abi.decode(entries[entries.length - 1].data, (RequestBuilder.Request)); // parse event params.
        requestId = req.id;
        console.log("singleRequest's id: %s", Strings.toHexString(uint256(requestId), 32));
        CapsulatedValue[] memory results = new CapsulatedValue[](1);
        results[0] = CapsulatedValue(0, 129);
        oracle.callback(requestId, results);
        assertEq(euint64.unwrap(example.myValue()), 0);
    }
}
