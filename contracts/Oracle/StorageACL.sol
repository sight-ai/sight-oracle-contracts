// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Types.sol";
import "./access/Ownable.sol";

contract StorageACL is Ownable {
    mapping(address => mapping(address => bool)) allowed_callback_addr_records;
    mapping(address => address[]) allowed_callback_addrs;
    mapping(ebool => mapping(address => bool)) ebool_acl;
    mapping(ebool => address[]) ebool_acl_addrs;
    mapping(euint64 => mapping(address => bool)) euint64_acl;
    mapping(euint64 => address[]) euint64_acl_addrs;
    mapping(eaddress => mapping(address => bool)) eaddress_acl;
    mapping(eaddress => address[]) eaddress_acl_addrs;

    function allowedCallbackAddr(address owner, address delegated) public view returns (bool) {
        return allowed_callback_addr_records[owner][delegated];
    }

    function allowedCallbackAddrs(address owner) public view returns (address[] memory) {
        return allowed_callback_addrs[owner];
    }

    function allowCallbackAddr(address delegated, bool enable) public {
        if (enable) {
            if (!allowedCallbackAddr(msg.sender, delegated)) {
                allowed_callback_addr_records[msg.sender][delegated] = enable;
                allowed_callback_addrs[msg.sender].push(delegated);
            }
        } else {
            if (allowedCallbackAddr(msg.sender, delegated)) {
                allowed_callback_addr_records[msg.sender][delegated] = enable;
                uint length = allowed_callback_addrs[msg.sender].length;
                uint i;
                uint j = length - 1;
                while (i <= j) {
                    if (allowed_callback_addrs[msg.sender][i] == delegated) {
                        allowed_callback_addrs[msg.sender][i] = allowed_callback_addrs[msg.sender][j];
                        j--;
                    } else {
                        i++;
                    }
                }
                for (uint k; k < length - i; k++) {
                    allowed_callback_addrs[msg.sender].pop();
                }
            }
        }
    }

    function isAccessibleEbool(address requester, ebool data) public view returns (bool) {
        return ebool_acl[data][requester];
    }

    function isAccessibleEuint64(address requester, euint64 data) public view returns (bool) {
        return euint64_acl[data][requester];
    }

    function isAccessibleEaddress(address requester, eaddress data) public view returns (bool) {
        return eaddress_acl[data][requester];
    }

    function setAccessibleEbool(address requester, ebool data, bool enable) public {
        require(
            owner() == msg.sender || ebool_acl[data][msg.sender],
            "msg.sender was neither storage owner nor data owner"
        );
        if (enable) {
            if (!isAccessibleEbool(requester, data)) {
                ebool_acl[data][requester] = true;
                ebool_acl_addrs[data].push(requester);
            }
        } else {
            if (isAccessibleEbool(requester, data)) {
                ebool_acl[data][requester] = false;
                uint length = ebool_acl_addrs[data].length;
                uint j;
                for (uint i; i < length; i++) {
                    if (requester != ebool_acl_addrs[data][i]) {
                        ebool_acl_addrs[data][j] = ebool_acl_addrs[data][i];
                        j++;
                    }
                }
                for (uint k; k < length - j; k++) {
                    ebool_acl_addrs[data].pop();
                }
            }
        }
    }

    function setAccessibleEuint64(address requester, euint64 data, bool enable) public {
        require(
            owner() == msg.sender || euint64_acl[data][msg.sender],
            "msg.sender was neither storage owner nor data owner"
        );
        if (enable) {
            if (!isAccessibleEuint64(requester, data)) {
                euint64_acl[data][requester] = true;
                euint64_acl_addrs[data].push(requester);
            }
        } else {
            if (isAccessibleEuint64(requester, data)) {
                euint64_acl[data][requester] = false;
                uint length = euint64_acl_addrs[data].length;

                uint i;
                uint j = length - 1;
                while (i <= j) {
                    if (euint64_acl_addrs[data][i] == requester) {
                        euint64_acl_addrs[data][i] = euint64_acl_addrs[data][j];
                        j--;
                    } else {
                        i++;
                    }
                }
                for (uint k; k < length - i; k++) {
                    euint64_acl_addrs[data].pop();
                }
            }
        }
    }

    function setAccessibleEaddress(address requester, eaddress data, bool enable) public {
        require(
            owner() == msg.sender || eaddress_acl[data][msg.sender],
            "msg.sender was neither storage owner nor data owner"
        );
        if (enable) {
            if (!isAccessibleEaddress(requester, data)) {
                eaddress_acl[data][requester] = true;
                eaddress_acl_addrs[data].push(requester);
            }
        } else {
            if (isAccessibleEaddress(requester, data)) {
                eaddress_acl[data][requester] = false;
                uint length = eaddress_acl_addrs[data].length;
                uint len = eaddress_acl_addrs[data].length;
                for (uint i; i < len; i++) {
                    if (requester == eaddress_acl_addrs[data][i]) {
                        for (uint j = i + 1; j < len; j++) {
                            eaddress_acl_addrs[data][j - 1] = eaddress_acl_addrs[data][j];
                        }
                        i--;
                        len--;
                    }
                }
                for (uint k; k < length - len; k++) {
                    eaddress_acl_addrs[data].pop();
                }
            }
        }
    }

    function getEboolOwners(ebool data) public view returns (address[] memory) {
        return ebool_acl_addrs[data];
    }

    function getEuint64Owners(euint64 data) public view returns (address[] memory) {
        return euint64_acl_addrs[data];
    }

    function getEaddressOwners(eaddress data) public view returns (address[] memory) {
        return eaddress_acl_addrs[data];
    }
}
