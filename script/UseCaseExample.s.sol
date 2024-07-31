// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { UseCaseExample } from "../src/UseCaseExample.sol";

contract UseCaseExampleScript is Script {
    function run() public {
        address oracle = vm.envAddress("ORACLE_ADDR");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        UseCaseExample uce = new UseCaseExample(address(oracle));
        uce.singleRequest();
        vm.stopBroadcast();
    }
}
