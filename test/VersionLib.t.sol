// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Test} from "forge-std/Test.sol";
import {VersionLib, Version} from "src/VersionLib.sol";
import {console2 as console} from "forge-std/console2.sol";
import {FACTORY_CODE, FACTORY_ADDR} from "./utils/Create2Constants.sol";

/// @author philogy <https://github.com/philogy>
contract VersionLibTest is Test {
    function setUp() public {
        vm.etch(FACTORY_ADDR, FACTORY_CODE);
    }

    function testVersion() public {
        console.log("version: %s", VersionLib.getVersion().toString());
    }
}
