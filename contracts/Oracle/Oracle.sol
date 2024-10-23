// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RequestBuilder.sol";
import "./ReencryptRequestBuilder.sol";
import "./SaveCiphertextRequestBuilder.sol";
import "./access/Ownable2Step.sol";
import "./constants/OracleAddresses.sol";

Oracle constant oracleOpSepolia = Oracle(ORACLE_ADDR_OP_SEPOLIA);

contract Oracle is Ownable2Step {
    mapping(bytes32 => Request) requests;
    mapping(bytes32 => ReencryptRequest) reenc_requests;
    mapping(bytes32 => SaveCiphertextRequest) save_ciphertext_requests;

    event RequestSent(bytes32 indexed reqId, Request req);
    event RequestCallback(bytes32 indexed reqId, bool indexed success);

    event ReencryptSent(bytes32 indexed reqId, ReencryptRequest req);
    event ReencryptCallback(bytes32 indexed reqId, bool indexed success);

    event SaveCiphertextSent(bytes32 indexed reqId, SaveCiphertextRequest req);
    event SaveCiphertextCallback(bytes32 indexed reqId, bool indexed success);

    string public constant VERSION = "0.0.3-SNAPSHOT";

    uint256 private nonce;

    function send(Request memory req) external returns (bytes32) {
        bytes32 reqId = keccak256(abi.encodePacked(nonce++, req.requester, block.number));
        Request storage request = requests[reqId];
        request.requester = req.requester;
        request.opsCursor = req.opsCursor;
        request.callbackAddr = req.callbackAddr;
        request.callbackFunc = req.callbackFunc;
        request.payload = req.payload;
        Operation[] storage ops = request.ops;
        for (uint256 i; i < req.ops.length; i++) {
            ops.push(req.ops[i]);
        }
        emit RequestSent(reqId, request);
        return reqId;
    }

    function callback(bytes32 reqId, CapsulatedValue[] memory result) public onlyOwner {
        Request memory req = requests[reqId];
        (bool success, bytes memory bb) = req.callbackAddr.call(
            abi.encodeWithSelector(req.callbackFunc, reqId, result)
        );
        if (!success) {
            string memory err = abi.decode(bb, (string));
            revert(err);
        }
        emit RequestCallback(reqId, success);
    }

    function send(ReencryptRequest memory req) public returns (bytes32) {
        bytes32 reqId = keccak256(abi.encodePacked(nonce++, req.requester, block.number));
        reenc_requests[reqId] = req;
        emit ReencryptSent(reqId, req);
        return reqId;
    }

    function reencryptCallback(bytes32 reqId, bytes memory result) public onlyOwner {
        ReencryptRequest memory req = reenc_requests[reqId];
        (bool success, bytes memory bb) = req.callbackAddr.call(
            abi.encodeWithSelector(req.callbackFunc, reqId, result)
        );
        if (!success) {
            string memory err = abi.decode(bb, (string));
            revert(err);
        }
        emit ReencryptCallback(reqId, success);
    }

    function send(SaveCiphertextRequest memory req) public returns (bytes32) {
        bytes32 reqId = keccak256(abi.encodePacked(nonce++, req.requester, block.number));
        emit SaveCiphertextSent(reqId, req);
        delete req.ciphertext;
        save_ciphertext_requests[reqId] = req;
        return reqId;
    }

    function saveCiphertextCallback(bytes32 reqId, CapsulatedValue memory result) public onlyOwner {
        SaveCiphertextRequest memory req = save_ciphertext_requests[reqId];
        (bool success, bytes memory bb) = req.callbackAddr.call(
            abi.encodeWithSelector(req.callbackFunc, reqId, result)
        );
        if (!success) {
            string memory err = abi.decode(bb, (string));
            revert(err);
        }
        emit SaveCiphertextCallback(reqId, success);
    }
}
