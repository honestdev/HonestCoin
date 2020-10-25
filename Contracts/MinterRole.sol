pragma solidity 0.5.12;

import Roles.sol;
import Ownable.sol;

/**
 * @title MinterRole
 */
contract MinterRole is Ownable {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    modifier onlyMinter() {
        require(isMinter(msg.sender), "Caller has no permission");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return(_minters.has(account) || _isOwner(account));
    }

    function addMinter(address account) public onlyOwner {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function removeMinter(address account) public onlyOwner {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}
