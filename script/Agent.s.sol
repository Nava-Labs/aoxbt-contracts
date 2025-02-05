// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {AgentRouter} from "../src/AgentRouter.sol";
import {Pool} from "../src/Pool.sol";

contract DeployAgentContract is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        Pool _pool = new Pool();

        AgentRouter _agentRouter = new AgentRouter(address(_pool));

        vm.stopBroadcast();

        console.log(
            "contract Pool deployed on with address: ",
            address(_pool)
        );

        console.log(
            "contract Agent Router deployed on with address: ",
            address(_agentRouter)
        );

        
    }
}