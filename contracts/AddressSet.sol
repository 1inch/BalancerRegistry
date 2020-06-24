pragma solidity ^0.5.0;


library AddressSet {
    struct Data {
        address[] items;
        mapping(address => uint) lookup;
    }

    function length(Data storage s) internal view returns(uint) {
        return s.items.length;
    }

    function at(Data storage s, uint index) internal view returns(address) {
        return s.items[index];
    }

    function contains(Data storage s, address item) internal view returns(bool) {
        return s.lookup[item] != 0;
    }

    function add(Data storage s, address item) internal returns(bool) {
        if (s.lookup[item] == 0) {
            s.lookup[item] = s.items.push(item);
            return true;
        }
    }

    function remove(Data storage s, address item) internal returns(bool) {
        uint index = s.lookup[item];
        if (index > 0) {
            if (index < s.items.length) {
                address lastItem = s.items[s.items.length - 1];
                s.items[index - 1] = lastItem;
                s.lookup[lastItem] = index;
            }
            s.items.length -= 1;
            delete s.lookup[item];
            return true;
        }
    }
}
