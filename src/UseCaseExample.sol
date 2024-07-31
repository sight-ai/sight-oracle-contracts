// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@sight-ai/contracts/Types.sol";
import "@sight-ai/contracts/Oracle.sol";
import "@sight-ai/contracts/RequestBuilder.sol";
import "@sight-ai/contracts/ReencryptRequestBuilder.sol";
import "@sight-ai/contracts/ResponseResolver.sol";

contract UseCaseExample {
    using RequestBuilder for RequestBuilder.Request;

    address public oracleAddress;
    ebool public myValue;
    euint64 public myValue1;
    euint64 public myValue2;

    constructor(address _oracleAddress) {
        oracleAddress = _oracleAddress;
    }

    // This example shows a + b compared with a + c + 10
    function makeComplicatedRequest() public {
        // Initialize a new Request with a predefined length for the operations array
        RequestBuilder.Request memory r = RequestBuilder.newRequest(
            msg.sender,
            7, // Adjust this length as needed for gas-efficiency
            address(this),
            this.callback.selector,
            msg.data
        );

        // Step 1: Create EncryptedValue A
        op encryptedValueA = r.rand();

        // Step 2: Create EncryptedValue B
        op encryptedValueB = r.rand();

        // Step 3: Add A and B to get the result
        op sumAB = r.add(encryptedValueA, encryptedValueB);

        // Step 4: Create EncryptedValue C
        op encryptedValueC = r.rand();

        // Step 5: Add A and C
        op sumAC = r.add(encryptedValueA, encryptedValueC);

        // Step 6: Add result in step 5 with plaintext 10
        op sumACPlus10 = r.add(sumAC, 10);

        // Step 7: Compare the result in step 3 with the result in step 6
        /* op comparisonResult =  */ r.gt(sumAB, sumACPlus10);

        r.complete();

        // Send the request to the Oracle
        Oracle(oracleAddress).send(r);
    }

    function callback(bytes32 /* requestId */, CapsulatedValue[] memory results) public {
        myValue = ResponseResolver.asEbool(results[results.length - 1]);
    }

    function singleRequest() public {
        RequestBuilder.Request memory r = RequestBuilder.newRequest(
            msg.sender,
            1, // Adjust this length as needed for gas-efficiency
            address(this),
            this.callback1.selector,
            msg.data
        );
        /* op result =  */ r.rand();
        r.complete();
        Oracle(oracleAddress).send(r);
    }

    function callback1(bytes32 /* requestId */, CapsulatedValue[] memory results) public {
        myValue1 = ResponseResolver.asEuint64(results[results.length - 1]);
    }

    function secondRequest() public {
        RequestBuilder.Request memory r = RequestBuilder.newRequest(
            msg.sender,
            3, // Adjust this length as needed for gas-efficiency
            address(this),
            this.callback2.selector,
            msg.data
        );
        op op1 = r.getEuint64(myValue1);
        op op2 = r.rand();
        /* op result =  */ r.add(op1, op2);
        r.complete();
        Oracle(oracleAddress).send(r);
    }

    function callback2(bytes32 /* requestId */, CapsulatedValue[] memory results) public {
        myValue2 = ResponseResolver.asEuint64(results[results.length - 1]);
    }

    fallback() external payable {}
    receive() external payable {}
}
