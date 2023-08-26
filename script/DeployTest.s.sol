// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {VersionLib} from "src/VersionLib.sol";

contract Dud {
    function version() external returns (string memory) {
        return VersionLib.getVersion().toString();
    }
}

/// @author philogy <https://github.com/philogy>
contract DeployTestScript is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("PRIV_KEY"));
        new Dud();
        vm.stopBroadcast();
    }
}
