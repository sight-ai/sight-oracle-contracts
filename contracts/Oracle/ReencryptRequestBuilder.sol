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
        address oracleAddr,
        address callbackAddr,
        bytes4 callbackFunc
    ) internal view returns (ReencryptRequest memory) {
        require(target.valueType != 0, "not initialized data");
        if (target.valueType == Types.T_EBOOL) {
            require(
                Oracle(oracleAddr).isOwnedEbool(requester, ebool.wrap(target.data)),
                "requester not own ebool data"
            );
        } else if (target.valueType == Types.T_EUINT64) {
            require(
                Oracle(oracleAddr).isOwnedEuint64(requester, euint64.wrap(target.data)),
                "requester not own euint64 data"
            );
        } else if (target.valueType == Types.T_EADDRESS) {
            require(
                Oracle(oracleAddr).isOwnedEaddress(requester, eaddress.wrap(target.data)),
                "requester not own eaddress data"
            );
        }
        ReencryptRequest memory r = ReencryptRequest({
            requester: requester,
            target: target,
            publicKey: publicKey,
            signature: signature,
            oracleAddr: oracleAddr,
            callbackAddr: callbackAddr,
            callbackFunc: callbackFunc
        });
        return r;
    }
}
