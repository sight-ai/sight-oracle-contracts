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

    string public VERSION = "0.0.2";

    function send(Request calldata request) external {
        require(request.id != bytes32(0), "id not generated, use .complete()");
        requests[request.id] = request;
        emit RequestSent(request);
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

    function send(ReencryptRequest calldata reen_req) public {
        reenc_requests[reen_req.id] = reen_req;
        emit ReencryptSent(reen_req);
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

    function send(SaveCiphertextRequest memory scr) public {
        emit SaveCiphertextSent(scr);
        delete scr.ciphertext;
        save_ciphertext_requests[scr.id] = scr;
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
