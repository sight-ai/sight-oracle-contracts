// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Types.sol";
import "./Reencrypt.sol";
import "./RequestBuilder.sol";
import "./ReencryptRequestBuilder.sol";
import "./SaveCiphertextRequestBuilder.sol";
import "./access/Ownable2Step.sol";
import "./constants/OracleAddresses.sol";

Oracle constant oracleOpSepolia = Oracle(ORACLE_ADDR_OP_SEPOLIA);

contract Oracle is Ownable2Step, Reencrypt {
    mapping(bytes32 => Request) requests;
    mapping(bytes32 => ReencryptRequest) reenc_requests;
    mapping(bytes32 => SaveCiphertextRequest) save_ciphertext_requests;
    mapping(address => mapping(address => bool)) callback_allowed;
    mapping(ebool => mapping(address => bool)) ebool_owners;
    mapping(euint64 => mapping(address => bool)) euint64_owners;
    mapping(eaddress => mapping(address => bool)) eaddress_owners;
    mapping(ebool => uint256) ebool_owners_counts;
    mapping(euint64 => uint256) euint64_owners_counts;
    mapping(eaddress => uint256) eaddress_owners_counts;

    event RequestSent(bytes32 indexed reqId, Request req);
    event RequestCallback(bytes32 indexed reqId, bool indexed success);

    event ReencryptSent(bytes32 indexed reqId, ReencryptRequest req);
    event ReencryptCallback(bytes32 indexed reqId, bool indexed success);

    event SaveCiphertextSent(bytes32 indexed reqId, SaveCiphertextRequest req);
    event SaveCiphertextCallback(bytes32 indexed reqId, bool indexed success);

    string public constant VERSION = "0.0.3-release";

    uint256 private nonce;
    mapping(address => uint8) private callers;

    function allowCallbackAddr(address callbackAddr, bool enable) public {
        callback_allowed[msg.sender][callbackAddr] = enable;
    }

    function isOwnedEbool(address owner, ebool data) public view returns (bool) {
        return ebool_owners[data][owner];
    }

    function isOwnedEuint64(address owner, euint64 data) public view returns (bool) {
        return euint64_owners[data][owner];
    }

    function isOwnedEaddress(address owner, eaddress data) public view returns (bool) {
        return eaddress_owners[data][owner];
    }

    function setEboolOwner(address owner, ebool data) internal {
        if (!isOwnedEbool(owner, data)) {
            ebool_owners[data][owner] = true;
            ebool_owners_counts[data] += 1;
        }
    }

    function setEuint64Owner(address owner, euint64 data) internal {
        if (!isOwnedEuint64(owner, data)) {
            euint64_owners[data][owner] = true;
            euint64_owners_counts[data] += 1;
        }
    }

    function setEaddressOwner(address owner, eaddress data) internal {
        if (!isOwnedEaddress(owner, data)) {
            eaddress_owners[data][owner] = true;
            eaddress_owners_counts[data] += 1;
        }
    }

    function setEboolOwner(address owner, ebool data, bool enable) public {
        require(isOwnedEbool(msg.sender, data), "sender not own data");
        if (enable) {
            setEboolOwner(owner, data);
        } else {
            ebool_owners[data][owner] = false;
            ebool_owners_counts[data] -= 1;
            require(ebool_owners_counts[data] > 0, "data needs one owner");
        }
    }

    function setEuint64Owner(address owner, euint64 data, bool enable) public {
        require(isOwnedEuint64(msg.sender, data), "sender not own data");
        if (enable) {
            setEuint64Owner(owner, data);
        } else {
            euint64_owners[data][owner] = false;
            euint64_owners_counts[data] -= 1;
            require(euint64_owners_counts[data] > 0, "data needs one owner");
        }
    }

    function setEaddressOwner(address owner, eaddress data, bool enable) public {
        require(isOwnedEaddress(msg.sender, data), "sender not own data");
        if (enable) {
            setEaddressOwner(owner, data);
        } else {
            eaddress_owners[data][owner] = false;
            eaddress_owners_counts[data] -= 1;
            require(eaddress_owners_counts[data] > 0, "data needs one owner");
        }
    }

    function send(Request memory req) external allowedCallbackAddr(req.callbackAddr) returns (bytes32) {
        bytes32 reqId = keccak256(abi.encodePacked(nonce++, req.requester, block.number));
        Request storage request = requests[reqId];
        request.requester = req.requester;
        request.opsCursor = req.opsCursor;
        request.oracleAddr = req.oracleAddr;
        request.callbackAddr = req.callbackAddr;
        request.callbackFunc = req.callbackFunc;
        request.payload = req.payload;
        Operation[] storage ops = request.ops;
        for (uint256 i; i < req.ops.length; i++) {
            if (req.ops[i].opcode == Opcode.get_ebool) {
                require(
                    isOwnedEbool(req.requester, ebool.wrap(req.ops[i].operands[0])),
                    "requester not own ebool data"
                );
            } else if (req.ops[i].opcode == Opcode.get_euint64) {
                require(
                    isOwnedEuint64(req.requester, euint64.wrap(req.ops[i].operands[0])),
                    "requester not own euint64 data"
                );
            } else if (req.ops[i].opcode == Opcode.get_eaddress) {
                require(
                    isOwnedEaddress(req.requester, eaddress.wrap(req.ops[i].operands[0])),
                    "requester not own eaddress data"
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
                setEboolOwner(req.requester, ebool.wrap(result[i].data));
            } else if (result[i].valueType == Types.T_EUINT64) {
                setEuint64Owner(req.requester, euint64.wrap(result[i].data));
            } else if (result[i].valueType == Types.T_EADDRESS) {
                setEaddressOwner(req.requester, eaddress.wrap(result[i].data));
            }
        }
        emit RequestCallback(reqId, success);
    }

    function send(
        ReencryptRequest memory req
    ) public onlySignedPublicKey(req.publicKey, req.signature) allowedCallbackAddr(req.callbackAddr) returns (bytes32) {
        bytes32 reqId = keccak256(abi.encodePacked(nonce++, req.requester, block.number));

        if (req.target.valueType == Types.T_EBOOL) {
            require(isOwnedEbool(req.requester, ebool.wrap(req.target.data)), "requester not own ebool data");
        } else if (req.target.valueType == Types.T_EUINT64) {
            require(isOwnedEuint64(req.requester, euint64.wrap(req.target.data)), "requester not own euint64 data");
        } else if (req.target.valueType == Types.T_EADDRESS) {
            require(isOwnedEaddress(req.requester, eaddress.wrap(req.target.data)), "requester not own eaddress data");
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

    function send(SaveCiphertextRequest memory req) public allowedCallbackAddr(req.callbackAddr) returns (bytes32) {
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
            setEboolOwner(req.requester, ebool.wrap(result.data));
        } else if (result.valueType == Types.T_EUINT64) {
            setEuint64Owner(req.requester, euint64.wrap(result.data));
        } else if (result.valueType == Types.T_EADDRESS) {
            setEaddressOwner(req.requester, eaddress.wrap(result.data));
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

    modifier allowedCallbackAddr(address callbackAddr) {
        require(
            msg.sender == callbackAddr || callback_allowed[msg.sender][callbackAddr],
            "Callback Address not allowed."
        );
        _;
    }
}
