
//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

struct AppStorage {
    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    mapping(address => Counters.Counter) nonces;    
}

library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}