// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Test} from "forge-std/Test.sol";
import {VersionLib, Version} from "src/VersionLib.sol";
import {Shanghai} from "src/detectors/Constants.sol";
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
        address deployed = deployHuffWithVersion("src/examples/Choice.huff", "paris");
        emit log_named_bytes("deployed.code", deployed.code);
    }

    function testViewVersionUnknown() public {
        address viewVersion = deployHuffWithVersion("test/mocks/ViewVersionGet.huff", "paris");
        (bool success, bytes memory ret) = viewVersion.staticcall(new bytes(0));
        assertTrue(success);
        uint256 v = abi.decode(ret, (uint256));
        assertEq(v, 0);
    }

    function testViewVersionKnown() public {
        address viewVersion = deployHuffWithVersion("test/mocks/ViewVersionGet.huff", "paris");
        VersionLib.FACTORY.safeCreate2(Shanghai.SALT, Shanghai.CODE);
        (bool success, bytes memory ret) = viewVersion.staticcall(new bytes(0));
        assertTrue(success);
        uint256 v = abi.decode(ret, (uint256));
        console.log("version: %d", v);
    }

    function deployHuffWithVersion(string memory file, string memory version) internal returns (address deployed) {
        bytes memory code = getHuffWithVersion(file, version);
        /// @solidity memory-safe-assembly
        assembly {
            deployed := create(0, add(code, 0x20), mload(code))
        }
        assertTrue(deployed != address(0), "DEPLOY_FAILED");
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
