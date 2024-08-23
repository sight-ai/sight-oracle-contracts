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

    event RequestSent(Request);
    event RequestCallback(bytes32 indexed, bool indexed);

    event ReencryptSent(ReencryptRequest);
    event ReencryptCallback(bytes32 indexed, bool indexed);

    event SaveCiphertextSent(SaveCiphertextRequest);
    event SaveCiphertextCallback(bytes32 indexed, bool indexed);

    string public constant VERSION = "0.0.2-SNAPSHOT";

    uint256 private nonce;

    function send(Request memory request) external returns (bytes32) {
        request.id = keccak256(abi.encodePacked(nonce++, request.requester, block.number));
        Request storage req = requests[request.id];
        req.id = request.id;
        req.requester = request.requester;
        req.opsCursor = request.opsCursor;
        req.callbackAddr = request.callbackAddr;
        req.callbackFunc = request.callbackFunc;
        req.payload = request.payload;
        Operation[] storage ops = req.ops;
        for (uint256 i; i < request.ops.length; i++) {
            ops.push(request.ops[i]);
        }
        emit RequestSent(request);
        return request.id;
    }

    function callback(bytes32 requestId, CapsulatedValue[] memory result) public onlyOwner {
        Request memory request = requests[requestId];
        (bool success, bytes memory bb) = request.callbackAddr.call(
            abi.encodeWithSelector(request.callbackFunc, requestId, result)
        );
        if (!success) {
            string memory err = abi.decode(bb, (string));
            revert(err);
        }
        emit RequestCallback(requestId, success);
    }

    function send(ReencryptRequest memory reen_req) public returns (bytes32) {
        reen_req.id = keccak256(abi.encodePacked(nonce++, reen_req.requester, block.number));
        reenc_requests[reen_req.id] = reen_req;
        emit ReencryptSent(reen_req);
        return reen_req.id;
    }

    function reencryptCallback(bytes32 requestId, bytes memory result) public onlyOwner {
        ReencryptRequest memory reen_req = reenc_requests[requestId];
        (bool success, bytes memory bb) = reen_req.callbackAddr.call(
            abi.encodeWithSelector(reen_req.callbackFunc, reen_req.id, result)
        );
        if (!success) {
            string memory err = abi.decode(bb, (string));
            revert(err);
        }
        emit ReencryptCallback(requestId, success);
    }

    function send(SaveCiphertextRequest memory scr) public returns (bytes32) {
        scr.id = keccak256(abi.encodePacked(nonce++, scr.requester, block.number));
        emit SaveCiphertextSent(scr);
        delete scr.ciphertext;
        save_ciphertext_requests[scr.id] = scr;
        return scr.id;
    }

    function saveCiphertextCallback(bytes32 requestId, CapsulatedValue memory result) public onlyOwner {
        SaveCiphertextRequest memory scr = save_ciphertext_requests[requestId];
        (bool success, bytes memory bb) = scr.callbackAddr.call(
            abi.encodeWithSelector(scr.callbackFunc, scr.id, result)
        );
        if (!success) {
            string memory err = abi.decode(bb, (string));
            revert(err);
        }
        emit SaveCiphertextCallback(requestId, success);
    }
}
