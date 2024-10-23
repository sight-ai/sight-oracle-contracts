// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { CapsulatedValue, SaveCiphertextRequest } from "./Types.sol";

library SaveCiphertextRequestBuilder {
    function newSaveCiphertextRequest(
        address requester,
        bytes calldata ciphertext,
        uint8 ciphertextType,
        address callbackAddr,
        bytes4 callbackFunc
    ) internal pure returns (SaveCiphertextRequest memory) {
        SaveCiphertextRequest memory r = SaveCiphertextRequest({
            requester: requester,
            ciphertext: ciphertext,
            ciphertextType: ciphertextType,
            callbackAddr: callbackAddr,
            callbackFunc: callbackFunc
        });
        return r;
    }
}
