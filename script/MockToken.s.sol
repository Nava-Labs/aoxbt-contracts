// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {StandardToken} from "../src/Mock/MockToken.sol";

contract DeployMockToken is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        StandardToken _token1 = new StandardToken("DOGE", "DOGE", 18, 1000 ether);

        StandardToken _token2 = new StandardToken("SPX", "SPX", 18, 1000 ether);

        StandardToken _token3 = new StandardToken("HyperLiquid", "HYPE", 18, 1000 ether);

        vm.stopBroadcast();

        console.log(
            "contract Mock Token 1 deployed on with address: ",
            address(_token1)
        );

         console.log(
            "contract Mock Token 2 deployed on with address: ",
            address(_token2)
        );

         console.log(
            "contract Mock Token 3 deployed on with address: ",
            address(_token3)
        );
    }
}