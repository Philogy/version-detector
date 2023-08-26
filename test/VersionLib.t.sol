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

    function testHuffChoice() public {
        bytes memory code = getHuffWithVersion("src/examples/Choice.huff", "paris");
        address deployed;
        /// @solidity memory-safe-assembly
        assembly {
            deployed := create(0, add(code, 0x20), mload(code))
        }
        assertTrue(deployed != address(0), "DEPLOY_FAILED");
        emit log_named_bytes("deployed.code", deployed.code);
    }

    function getHuffWithVersion(string memory file, string memory version) internal returns (bytes memory code) {
        string[] memory args = new string[](5);
        args[0] = "huffc";
        args[1] = "-b";
        args[2] = file;
        args[3] = "-e";
        args[4] = version;
        code = vm.ffi(args);
    }
}
