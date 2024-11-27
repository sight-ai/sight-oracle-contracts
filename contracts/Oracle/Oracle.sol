// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Types.sol";
import "./Reencrypt.sol";
import "./RequestBuilder.sol";
import "./ReencryptRequestBuilder.sol";
import "./SaveCiphertextRequestBuilder.sol";
import "./access/Ownable2Step.sol";
import "./constants/OracleAddresses.sol";
import "./StorageACL.sol";

Oracle constant oracleOpSepolia = Oracle(ORACLE_ADDR_OP_SEPOLIA);

contract Oracle is Ownable2Step, Reencrypt {
    mapping(bytes32 => Request) requests;
    mapping(bytes32 => ReencryptRequest) reenc_requests;
    mapping(bytes32 => SaveCiphertextRequest) save_ciphertext_requests;

    event RequestSent(bytes32 indexed reqId, Request req);
    event RequestCallback(bytes32 indexed reqId, bool indexed success);

    event ReencryptSent(bytes32 indexed reqId, ReencryptRequest req);
    event ReencryptCallback(bytes32 indexed reqId, bool indexed success);

    event SaveCiphertextSent(bytes32 indexed reqId, SaveCiphertextRequest req);
    event SaveCiphertextCallback(bytes32 indexed reqId, bool indexed success);

    string public constant VERSION = "0.0.3-release";

    uint256 private nonce;
    StorageACL public acl;
    mapping(address => uint8) private callers;

    function setStorageACL(address acl_) public onlyCallers {
        acl = StorageACL(acl_);
    }

    function send(Request memory req) external allowCallbackAddr(msg.sender, req.callbackAddr) returns (bytes32) {
        bytes32 reqId = keccak256(abi.encodePacked(nonce++, req.requester, block.number));
        Request storage request = requests[reqId];
        request.requester = req.requester;
        request.opsCursor = req.opsCursor;
        request.callbackAddr = req.callbackAddr;
        request.callbackFunc = req.callbackFunc;
        request.payload = req.payload;
        Operation[] storage ops = request.ops;
        for (uint256 i; i < req.ops.length; i++) {
            if (req.ops[i].opcode == Opcode.get_ebool) {
                require(
                    acl.isAccessibleEbool(req.callbackAddr, ebool.wrap(req.ops[i].operands[0])),
                    "callbackAddr not own ebool data"
                );
            } else if (req.ops[i].opcode == Opcode.get_euint64) {
                require(
                    acl.isAccessibleEuint64(req.callbackAddr, euint64.wrap(req.ops[i].operands[0])),
                    "callbackAddr not own euint64 data"
                );
            } else if (req.ops[i].opcode == Opcode.get_eaddress) {
                require(
                    acl.isAccessibleEaddress(req.callbackAddr, eaddress.wrap(req.ops[i].operands[0])),
                    "callbackAddr not own eaddress data"
                );
            }
            ops.push(req.ops[i]);
        }
        emit RequestSent(reqId, request);
        return reqId;
    }

    function callback(bytes32 reqId, CapsulatedValue[] memory result) public onlyCallers {
        Request memory req = requests[reqId];
        (bool success, bytes memory bb) = req.callbackAddr.call(
            abi.encodeWithSelector(req.callbackFunc, reqId, result)
        );
        if (!success) {
            string memory err = abi.decode(bb, (string));
            revert(err);
        }
        for (uint i; i < result.length; i++) {
            if (result[i].valueType == Types.T_EBOOL) {
                acl.setAccessibleEbool(req.callbackAddr, ebool.wrap(result[i].data), true);
            } else if (result[i].valueType == Types.T_EUINT64) {
                acl.setAccessibleEuint64(req.callbackAddr, euint64.wrap(result[i].data), true);
            } else if (result[i].valueType == Types.T_EADDRESS) {
                acl.setAccessibleEaddress(req.callbackAddr, eaddress.wrap(result[i].data), true);
            }
        }
        emit RequestCallback(reqId, success);
    }

    function send(
        ReencryptRequest memory req
    )
        public
        onlySignedPublicKey(req.publicKey, req.signature)
        allowCallbackAddr(msg.sender, req.callbackAddr)
        returns (bytes32)
    {
        bytes32 reqId = keccak256(abi.encodePacked(nonce++, req.requester, block.number));

        if (req.target.valueType == Types.T_EBOOL) {
            require(
                acl.isAccessibleEbool(req.callbackAddr, ebool.wrap(req.target.data)),
                "callbackAddr not own ebool data"
            );
        } else if (req.target.valueType == Types.T_EUINT64) {
            require(
                acl.isAccessibleEuint64(req.callbackAddr, euint64.wrap(req.target.data)),
                "callbackAddr not own euint64 data"
            );
        } else if (req.target.valueType == Types.T_EADDRESS) {
            require(
                acl.isAccessibleEaddress(req.callbackAddr, eaddress.wrap(req.target.data)),
                "callbackAddr not own eaddress data"
            );
        }
        reenc_requests[reqId] = req;
        emit ReencryptSent(reqId, req);
        return reqId;
    }

    function reencryptCallback(bytes32 reqId, bytes memory result) public onlyCallers {
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

    function send(
        SaveCiphertextRequest memory req
    ) public allowCallbackAddr(msg.sender, req.callbackAddr) returns (bytes32) {
        bytes32 reqId = keccak256(abi.encodePacked(nonce++, req.requester, block.number));
        emit SaveCiphertextSent(reqId, req);
        delete req.ciphertext;
        save_ciphertext_requests[reqId] = req;
        return reqId;
    }

    function saveCiphertextCallback(bytes32 reqId, CapsulatedValue memory result) public onlyCallers {
        SaveCiphertextRequest memory req = save_ciphertext_requests[reqId];
        (bool success, bytes memory bb) = req.callbackAddr.call(
            abi.encodeWithSelector(req.callbackFunc, reqId, result)
        );
        if (!success) {
            string memory err = abi.decode(bb, (string));
            revert(err);
        }
        if (result.valueType == Types.T_EBOOL) {
            acl.setAccessibleEbool(req.callbackAddr, ebool.wrap(result.data), true);
        } else if (result.valueType == Types.T_EUINT64) {
            acl.setAccessibleEuint64(req.callbackAddr, euint64.wrap(result.data), true);
        } else if (result.valueType == Types.T_EADDRESS) {
            acl.setAccessibleEaddress(req.callbackAddr, eaddress.wrap(result.data), true);
        }
        emit SaveCiphertextCallback(reqId, success);
    }

    function addCallers(address[] memory _callers) public onlyOwner {
        for (uint8 i; i < _callers.length; i++) {
            callers[_callers[i]] = 1;
        }
    }

    function deleteCallers(address[] memory _callers) public onlyOwner {
        for (uint8 i; i < _callers.length; i++) {
            delete callers[_callers[i]];
        }
    }

    modifier onlyCallers() {
        require(callers[msg.sender] == 1, "Sender Not In The Callers.");
        _;
    }

    modifier allowCallbackAddr(address owner, address delegated) {
        require(
            owner == delegated || acl.allowedCallbackAddr(owner, delegated),
            "callbackAddr is not allowed to the user contract"
        );
        _;
    }
}
