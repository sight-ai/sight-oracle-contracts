// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RequestBuilder.sol";
import "./ReencryptRequestBuilder.sol";
import "./access/Ownable2Step.sol";

contract Oracle is Ownable2Step {
    mapping(bytes32 => RequestBuilder.Request) requests;
    mapping(bytes32 => ReencryptRequestBuilder.ReencryptRequest) reenc_requests;

    event RequestSent(RequestBuilder.Request);
    event RequestCallback(bytes32 indexed, bool indexed);

    event ReencryptSent(ReencryptRequestBuilder.ReencryptRequest);
    event ReencryptCallback(bytes32 indexed, bool indexed);

    function send(RequestBuilder.Request calldata request) external {
        require(request.id != bytes32(0), "id not generated, use .complete()");
        requests[request.id] = request;
        emit RequestSent(request);
    }

    function callback(bytes32 requestId, CapsulatedValue[] memory result) public onlyOwner {
        RequestBuilder.Request memory request = requests[requestId];
        (bool success, bytes memory bb) = request.callbackAddr.call(
            abi.encodeWithSelector(request.callbackFunc, requestId, result)
        );
        if (!success) {
            string memory err = abi.decode(bb, (string));
            revert(err);
        }
        emit RequestCallback(requestId, success);
    }

    function send(ReencryptRequestBuilder.ReencryptRequest calldata reen_req) public {
        reenc_requests[reen_req.id] = reen_req;
        emit ReencryptSent(reen_req);
    }

    function reencryptCallback(bytes32 requestId, bytes memory result) public onlyOwner {
        ReencryptRequestBuilder.ReencryptRequest memory reen_req = reenc_requests[requestId];
        (bool success, bytes memory bb) = reen_req.callbackAddr.call(
            abi.encodeWithSelector(reen_req.callbackFunc, reen_req.id, result)
        );
        if (!success) {
            string memory err = abi.decode(bb, (string));
            revert(err);
        }
        emit ReencryptCallback(requestId, success);
    }
}
