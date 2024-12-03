// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Types.sol";
import "./access/Ownable.sol";

contract StorageACL is Ownable {
    mapping(address => mapping(address => bool)) allowed_callback_addr_records;
    mapping(address => address[]) allowed_callback_addrs;
    mapping(bytes32 => EType) type_records;
    mapping(bytes32 => address[]) value_owners;
    mapping(address => bytes32[]) owner_values;

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

    function setDataType(bytes32 data, EType eType) public {
        require(
            owner() == msg.sender || isAccessible(msg.sender, data),
            "msg.sender was neither storage owner nor data owner"
        );
        type_records[data] = eType;
    }

    function getDataType(bytes32 data) public view returns (EType) {
        require(type_records[data] != EType.Zero, "data not exists");
        return type_records[data];
    }

    function isAccessible(address requester, bytes32 data) public view returns (bool) {
        address[] memory owners = value_owners[data];
        for (uint i; i < owners.length; i++) {
            if (owners[i] == requester) return true;
        }
        return false;
    }

    function setAccessible(address requester, bytes32 data, bool enable) public {
        require(
            owner() == msg.sender || isAccessible(msg.sender, data),
            "msg.sender was neither storage owner nor data owner"
        );
        if (enable) {
            if (!isAccessible(requester, data)) {
                value_owners[data].push(requester);
                owner_values[requester].push(data);
            }
        } else {
            if (isAccessible(requester, data)) {
                uint length = value_owners[data].length;
                uint i;
                uint j = length - 1;
                while (i <= j) {
                    if (value_owners[data][i] == requester) {
                        value_owners[data][i] = value_owners[data][j];
                        j--;
                    } else {
                        i++;
                    }
                }
                for (uint k; k < length - i; k++) {
                    value_owners[data].pop();
                }

                length = value_owners[data].length;
                i = 0;
                j = length - 1;
                while (i <= j) {
                    if (owner_values[requester][i] == data) {
                        owner_values[requester][i] = owner_values[requester][j];
                        j--;
                    } else {
                        i++;
                    }
                }
                for (uint k; k < length - i; k++) {
                    owner_values[requester].pop();
                }
            }
        }
    }

    function getValueOwners(bytes32 value) public view returns (address[] memory) {
        return value_owners[value];
    }

    function getOwnerValues(address owner) public view returns (bytes32[] memory) {
        return owner_values[owner];
    }
}
