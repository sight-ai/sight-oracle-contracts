// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { CapsulatedValue, SaveCiphertextRequest } from "./Types.sol";

library SaveCiphertextRequestBuilder {
    function newSaveCiphertextRequest(
        address requester,
        bytes calldata ciphertext,
        uint8 ct_type,
        address callbackAddr,
        bytes4 callbackFunc,
        uint salt
    ) internal pure returns (SaveCiphertextRequest memory) {
        SaveCiphertextRequest memory r = SaveCiphertextRequest({
            id: keccak256(abi.encodePacked(requester, callbackAddr, ct_type, callbackFunc, salt)),
            requester: requester,
            ciphertext: ciphertext,
            ct_type: ct_type,
            callbackAddr: callbackAddr,
            callbackFunc: callbackFunc
        });
        return r;
    }
}
