// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Types.sol";

library ReencryptRequestBuilder {
    struct ReencryptRequest {
        bytes32 id;
        address requester;
        CapsulatedValue target;
        bytes32 publicKey;
        bytes signature;
        address callbackAddr;
        bytes4 callbackFunc;
    }

    function newReencryptRequest(
        address requester,
        CapsulatedValue memory target,
        bytes32 publicKey,
        bytes calldata signature,
        address callbackAddr,
        bytes4 callbackFunc
    ) internal pure returns (ReencryptRequest memory) {
        ReencryptRequest memory r = ReencryptRequest({
            // id shall remain the same since all encrypted data are immutable
            id: keccak256(abi.encodePacked(requester, target.data, target.valueType, publicKey, signature)),
            requester: requester,
            target: target,
            publicKey: publicKey,
            signature: signature,
            callbackAddr: callbackAddr,
            callbackFunc: callbackFunc
        });
        return r;
    }
}
