// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {AORouter} from "../src/AORouter.sol";

contract DeployAORouter is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        AORouter _router = new AORouter();

        vm.stopBroadcast();

        console.log(
            "contract Agent Orchestrator Router deployed on with address: ",
            address(_router)
        );
    }
}