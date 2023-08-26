# 🔍 Version Detector

A library for runtime EVM version detection.

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
    GET_VERSION(0x0)
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
