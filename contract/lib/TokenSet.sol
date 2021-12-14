
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.6.0;
library Set {
    struct Address {
        address[] _values;
        mapping (address => uint256) _indexes;
    }
   
    function add(Address storage set, address value) internal returns (bool) {
        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        }
        return false;
    }

    function remove(Address storage set, address value) internal returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            address lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1;
            set._values.pop();
            delete set._indexes[value];
            return true;
        }
         return false;
    }
   
    function contains(Address storage set, address value) internal view returns (bool) {
        return set._indexes[value] != 0;
    }
    
    function length(Address storage set) internal view returns (uint256) {
        return set._values.length;
    }
    
    function at(Address storage set, uint256 index) internal view returns (address) {
        require(set._values.length > index,"out of size");
        return set._values[index];
    }
    
}