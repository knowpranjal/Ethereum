// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract HandleRegistry {

    struct Handle {
        string handle;
        address owner;
    }

    mapping(string => Handle) public Handles;

    event HandleRegistered(string indexed key, string value);
    event HandleTransferred(string key, address newOwner);

    function RegisterHandle(string memory _id, string memory _handle) public {
        require(Handles[_id].owner == address(0), "Handle already exists");
        Handles[_id] = Handle(_handle, msg.sender);
        emit HandleRegistered(_id, _handle);
    }

    function transferHandle(string memory _id, address _newOwner) public {
        require(Handles[_id].owner == _newOwner, "Only the holder can request to transfer");
        Handles[_id].owner = _newOwner;
        emit HandleTransferred(_id, _newOwner);
    }

    function getHandleOwner(string memory _id) public view returns(address) {
        return Handles[_id].owner;
    }

}