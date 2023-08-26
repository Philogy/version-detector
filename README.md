# 🔍 Version Detector

A library for runtime EVM version detection.

## Motivation

As the EVM is improved and hardforks are activated the versions and therefore capabilities of
different EVM chains may differ. It may be useful to be able to do a runtime check of the EVM
version to ensure that contracts are either not deployed to chains where some of its instructions
are unsupported or to simply choose a compatible runtime implementation at deployment.

## Recognized Versions

|EVM Version / Version Cutoff| Indicator|Version Enum & Value|
|----------------------------|----------|--------------------|
|Unknown|Detectors missing on the target chain / unable to be deployed|`Version.Unknown` (`0x0`)|
|Pre-Shanghai|`PUSH0` (`0x5f`) uses more than 2 gas / reverts|`Version.PreShanghai` (`0x1`)|
|Post-Shanghai|`PUSH0` (`0x5f`) uses 2 or less gas & does not revert|`Version.PreShanghai` (`0x2`)|

## Usage

First install this repo as a dependency into your foundry project:

```bash
forge install philogy/version-detector --no-commit
```

### Solidity

In your contract import and then use the library e.g.:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {VersionLib, Version} from "version-detector/VersionLib.sol";

contract OnlyShanghai {
    constructor() {
        require(VersionLib.getVersion() >= Version.PostShanghai, "Incorrect Version");
    }
}
```

### Huff

In your code `#include` the library:

```
#include "../lib/version-detector/src/VersionLib.huff"
```

You can then use the `GET_VERSION` macro and version constants (`VERSION_UNKNOWN`, `VERSION_PRE_SHANGHAI` `VERSION_POST_SHANGHAI`):

```
#include "../lib/version-detector/src/VersionLib.huff"

#define table V1_DEFAULT {
    0x3d
}

#define table V2_SHANGHAI {
    0x5f
}

#define macro CONSTRUCTOR() = takes(0) returns(0) {
    GET_VERSION()
    [VERSION_POST_SHANGHAI]
    gt
    iszero
    v2 jumpi
    default:
        __tablesize(V1_DEFAULT)
        dup1
        __tablestart(V1_DEFAULT)
        0x0
        codecopy
        0x0
        return
    v2:
        __tablesize(V2_SHANGHAI)
        dup1
        __tablestart(V2_SHANGHAI)
        0x0
        codecopy
        0x0
        return
}

#define macro MAIN() = takes(0) returns(0) { }
```

## Documentation
### Solidity
#### [`VersionLib`](./src/VersionLib.sol)

**`getVersion() returns (Version)`**

A _non-view_ method that returns `Version` indicating the current chain's EVM version. May do a one time deployment of detectors if missing on the current chain. Expects the [`Immutable Create2 Factory`](https://etherscan.io/address/0x0000000000FFe8B47B3e2130213B802212439497) to deployed on the current chain and will revert if not deployed.

**`getVersionView() view returns (Version)`**

Similar to `getVersion` except that it will not deploy any missing detector contracts. May return
`Version.Unknown` if required detectors are missing on the current chain.

#### [`Version`](./src/VersionLib.sol)

**`toString() pure returns (string memory)`**

Returns a string representation of the version, can be useful for debugging. (Implemented as
`VersionLib.toString(Version version)` and mounted to the `Version` type via `using VersionLib for
Version global;`).

### Huff
#### [`GET_VERSION()`](./src/VersionLib.huff)

Similar to the Solidity `VersionLib.getVersion` function, the `GET_VERSION` macro will retrieve and push the version value as
a full word onto the stack. It'll deploy any detectors if missing and requires the same create2
factory to already be deployed on the chain. 

#### [`GET_VERSION_VIEW()`](./src/VersionLib.huff)

Similar to the Solidity `VersionLib.getVersionView` function, the `GET_VERSION_VIEW` macro will
check for the detectors and push the version to the stack, it will not deploy missing detector
contracts and will simple push the `Unknown` version (`0x0`) onto the stack if any necessary
contracts are missing.
