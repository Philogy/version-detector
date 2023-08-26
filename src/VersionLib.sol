// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICreate2Factory} from "./interfaces/ICreate2Factory.sol";


enum Version {
    Unknown,
    PreShanghai,
    PostShanghai
}

using VersionLib for Version global;

/// @author philogy <https://github.com/philogy>
library VersionLib {
    // ======================== Foundation =========================
    ICreate2Factory private constant FACTORY = ICreate2Factory(0x0000000000FFe8B47B3e2130213B802212439497);

    error MissingCreate2Factory();
    error UnrecognizedVersion();

    // ===================== Shanghai Detector =====================
    bytes32 private constant SHANGHAI_SALT = 0x00000000000000000000000000000000000000001510b57b210380000966a689;
    bytes private constant SHANGHAI_CODE = hex"60018060093d393df35f";
    address private constant SHANGHAI_DETECTOR = 0x000000005ea0cBe63A65f3383BFC4541c9520Ab5;

    function getVersion() internal returns (Version) {
        _ensureShanghai();
        return getShanghaiStatus();
    }

    function getShanghaiStatus() internal view returns (Version) {
        if (SHANGHAI_DETECTOR.code.length == 0) return Version.Unknown;
        (bool success,) = SHANGHAI_DETECTOR.staticcall{gas: 2}(new bytes(0));
        return success ? Version.PostShanghai : Version.PreShanghai;
    }

    function toString(Version version) internal pure returns (string memory s) {
        /// @solidity memory-safe-assembly
        assembly {
            s := mload(0x40)
            mstore(0x40, add(s, 0x40))
            switch version
            case 0 {
                /* Unknown */
                mstore(s, 15)
                mstore(add(s, 0x20), "Version.Unknown")
            }
            case 1 {
                /* PreShanghai */
                mstore(s, 19)
                mstore(add(s, 0x20), "Version.PreShanghai")
            }
            case 2 {
                /* PostShanghai */
                mstore(s, 20)
                mstore(add(s, 0x20), "Version.PostShanghai")
            }
            default {
                mstore(0x00, 0x3ad2e043) // `UnrecognizedVersion()`
                revert(0x1c, 0x04)
            }
        }
    }

    function _ensureShanghai() internal {
        if (SHANGHAI_DETECTOR.code.length == 0) {
            if (address(FACTORY).code.length == 0) revert MissingCreate2Factory();
            assert(FACTORY.safeCreate2(SHANGHAI_SALT, SHANGHAI_CODE) == SHANGHAI_DETECTOR);
        }
    }
}
