// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { Oracle } from "../contracts/Oracle/Oracle.sol";

contract OracleScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        /* Oracle oracle =  */ new Oracle();
        vm.stopBroadcast();
    }
}
