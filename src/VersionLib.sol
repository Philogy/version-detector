// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICreate2Factory} from "./interfaces/ICreate2Factory.sol";
import {Shanghai} from "./detectors/Constants.sol";

enum Version {
    Unknown,
    PreShanghai,
    PostShanghai
}

using VersionLib for Version global;

/// @author philogy <https://github.com/philogy>
library VersionLib {
    // ======================== Foundation =========================
    ICreate2Factory internal constant FACTORY = ICreate2Factory(0x0000000000FFe8B47B3e2130213B802212439497);

    error MissingCreate2Factory();
    error UnrecognizedVersion();

    function getVersion() internal returns (Version) {
        _ensureShanghai();
        return getVersionView();
    }

    function getVersionView() internal view returns (Version) {
        if (Shanghai.ADDR.code.length == 0) return Version.Unknown;
        (bool success,) = Shanghai.ADDR.staticcall{gas: 2}(new bytes(0));
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
        if (Shanghai.ADDR.code.length == 0) {
            if (address(FACTORY).code.length == 0) revert MissingCreate2Factory();
            assert(FACTORY.safeCreate2(Shanghai.SALT, Shanghai.CODE) == Shanghai.ADDR);
        }
    }
}
