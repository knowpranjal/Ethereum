// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract HandleRegistry {
    struct HandleDID {
        string handle;
        string did;
    }

    string s = "hassan";

    // Mappings for efficient lookups
    mapping(string => string) public handleToDID; 
    mapping(string => string) public didToHandle;

    // Arrays for indexing (keep track of registered handles/DIDs)
    string[] public registeredHandles;
    string[] public registeredDIDs;

    event HandleRegistered(string indexed _did, string indexed _handle);
    event DIDRetrieved(string indexed _handle);
    event HandleRetrieved(string indexed _did);

    function registerHandle(string memory _handle, string memory _did) public {
        require(bytes(handleToDID[_handle]).length == 0, "Handle already exists");
        require(bytes(didToHandle[_did]).length == 0, "DID already exists");

        handleToDID[_handle] = _did;
        didToHandle[_did] = _handle;
        registeredHandles.push(_handle);
        registeredDIDs.push(_did);

        emit HandleRegistered(_did, _handle);
    }

    function getDIDFromHandle(string memory _handle) public view returns (string memory) {
        // string memory did = handleToDID[_handle];
        // require(bytes(did).length > 0, "Handle not found"); 
        // emit DIDRetrieved(_handle);
        return "sss";
    }

    function getHandleFromDID(string memory _did) public returns (string memory) {
        string memory handle = didToHandle[_did];
        require(bytes(handle).length > 0, "DID not found");
        emit HandleRetrieved(_did);
        return handle;
    }

    // Simple functions for retrieving indexes
    function getRegisteredHandles() public view returns (string[] memory) {
        return registeredHandles;
    }

    function getRegisteredDIDs() public view returns (string[] memory) {
        return registeredDIDs;
    }
}
