// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract HandleRegistry {

    struct HandleDID {
        string handle;
        string did;
    }

    mapping(string => string) public handleToDID; 
    mapping(string => string) public didToHandle;

    string[] public registeredHandles;
    string[] public registeredDIDs;

    event HandleRegistered(string indexed _did, string indexed _handle);
    event HandleTransferred(string indexed _newdid);
    event DIDRetrieved(string indexed _handle);
    event HandleRetrieved(string indexed _did);

    error HandleAlreadyExists();
    error DIDAlreadyExists();
    error HandleNotFound();
    error DIDNotFound();

    function registerHandle(string memory _handle, string memory _did) public {
        require(bytes(_handle).length > 0, "Handle cannot be empty"); 
        require(bytes(_did).length > 0, "DID cannot be empty");

        if (bytes(handleToDID[_handle]).length != 0) {
            revert HandleAlreadyExists();
        }
        if (bytes(didToHandle[_did]).length != 0) {
            revert DIDAlreadyExists();
        }

        handleToDID[_handle] = _did;
        didToHandle[_did] = _handle;
        registeredHandles.push(_handle);
        registeredDIDs.push(_did);

        emit HandleRegistered(_did, _handle);
    }

    function transferHandle(string memory _handle, string memory _newDID) public {

        require(bytes(_newDID).length > 0, "New DID cannot be empty");

        if (bytes(handleToDID[_handle]).length == 0) {
            revert HandleNotFound();
        }

        string memory currentDID = handleToDID[_handle];
        
        require(keccak256(abi.encodePacked("did:ether:", msg.sender)) == keccak256(abi.encodePacked(currentDID)), "Unauthorized: Only handle owner can transfer");

        if (bytes(didToHandle[_newDID]).length != 0) {
            revert DIDAlreadyExists();
        }


        delete didToHandle[currentDID]; // Clear old DID association 
        handleToDID[_handle] = _newDID;
        didToHandle[_newDID] = _handle;

        for (uint256 i = 0; i < registeredDIDs.length; i++) {
            if (keccak256(abi.encodePacked(registeredDIDs[i])) == keccak256(abi.encodePacked(currentDID))) {
                registeredDIDs[i] = _newDID; // Replace old DID with new one
                break;
            }
        }

        emit HandleTransferred(_newDID);

    }

    function getDIDFromHandle(string memory _handle) public view returns (string memory) {
        string memory did = handleToDID[_handle];
        if (bytes(did).length == 0) {
            revert HandleNotFound();
        }
        return did;
    }

    function getHandleFromDID(string memory _did) public view returns (string memory) {
        string memory handle = didToHandle[_did];
        if (bytes(handle).length == 0) {
            revert DIDNotFound();
        }
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