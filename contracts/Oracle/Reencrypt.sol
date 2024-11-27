// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./utils/cryptography/ECDSA.sol";
import "./utils/cryptography/EIP712.sol";

abstract contract Reencrypt is EIP712 {
    constructor() EIP712("Authorization token", "1") {}

    modifier onlySignedPublicKey(bytes32 publicKey, bytes memory signature) {
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(keccak256("Reencrypt(bytes32 publicKey)"), publicKey)));
        address signer = ECDSA.recover(digest, signature);
        require(signer == tx.origin, "EIP712 signer and transaction signer do not match");
        _;
    }
}
