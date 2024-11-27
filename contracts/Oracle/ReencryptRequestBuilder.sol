// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { CapsulatedValue, ReencryptRequest, Types, ebool, euint64, eaddress } from "./Types.sol";
import { Oracle } from "./Oracle.sol";

library ReencryptRequestBuilder {
    function newReencryptRequest(
        address requester,
        CapsulatedValue memory target,
        bytes32 publicKey,
        bytes calldata signature,
        address callbackAddr,
        bytes4 callbackFunc
    ) internal pure returns (ReencryptRequest memory) {
        require(target.valueType != 0, "not initialized data");
        ReencryptRequest memory r = ReencryptRequest({
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
