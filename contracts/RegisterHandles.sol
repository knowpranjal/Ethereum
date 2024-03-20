// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract HandleRegistry {
    struct HandleDID {
        string handle;
        string did;
    }

    mapping(bytes32 => string) public handleToDID; // Mapping using hashes
    mapping(bytes32 => string) public didToHandle; // Mapping using hashes
    mapping(bytes32 => uint256) private didIndex;

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

    function startsWith(
        string memory str,
        string memory prefix
    ) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory prefixBytes = bytes(prefix);
        for (uint i = 0; i < prefixBytes.length; i++) {
            if (strBytes[i] != prefixBytes[i]) {
                return false;
            }
        }
        return true;
    }

    function registerHandle(string memory _handle, string memory _did) public {
        require(
            bytes(_handle).length > 0 && bytes(_handle).length <= 63,
            "Handle cannot be empty"
        );
        require(bytes(_did).length > 0, "DID cannot be empty");

        require(
            startsWith(_did, "did:ethr:"),
            "Format of DID is wrong, please enter it correctly."
        );

        bytes32 handleHash = keccak256(abi.encodePacked(_handle));
        bytes32 didHash = keccak256(abi.encodePacked(_did));

        if (bytes(handleToDID[handleHash]).length != 0) {
            revert HandleAlreadyExists();
        }
        if (bytes(didToHandle[didHash]).length != 0) {
            revert DIDAlreadyExists();
        }

        handleToDID[handleHash] = _did;
        didToHandle[didHash] = _handle;
        didIndex[didHash] = registeredDIDs.length; // Store index of DID
        registeredHandles.push(_handle);
        registeredDIDs.push(_did);

        emit HandleRegistered(_did, _handle);
    }

    function transferHandle(
        string memory _handle,
        string memory _newDID
    ) public {
        require(bytes(_newDID).length > 0, "New DID cannot be empty");
        require(
            bytes(_handle).length > 0 && bytes(_handle).length <= 63,
            "Format's wrong. Input previously registered handles only."
        );

        require(
            startsWith(_newDID, "did:ethr:"),
            "Wrong DID entered to transfer, enter an active DID."
        );

        bytes32 handleHash = keccak256(abi.encodePacked(_handle));
        bytes32 oldDIDHash = keccak256(abi.encodePacked(handleToDID[handleHash]));
        bytes32 newDIDHash = keccak256(abi.encodePacked(_newDID));

        if (bytes(handleToDID[handleHash]).length == 0) {
            revert HandleNotFound();
        }

        string memory currentDID = handleToDID[handleHash];

        require(
            keccak256(abi.encodePacked("did:ether:", msg.sender)) ==
                keccak256(abi.encodePacked(currentDID)),
            "Unauthorized: Only handle owner can transfer"
        );

        if (bytes(didToHandle[newDIDHash]).length != 0) {
            revert DIDAlreadyExists();
        }

        delete didToHandle[oldDIDHash]; 
        handleToDID[handleHash] = _newDID;
        didToHandle[newDIDHash] = _handle;

        uint256 indexToUpdate = didIndex[oldDIDHash]; // Retrieve index directly
        registeredDIDs[indexToUpdate] = _newDID;

        for (uint256 i = 0; i < registeredDIDs.length; i++) {
            if (
                keccak256(abi.encodePacked(registeredDIDs[i])) ==
                keccak256(abi.encodePacked(currentDID))
            ) {
                registeredDIDs[i] = _newDID; // Replace old DID with new one
                break;
            }
        }

        emit HandleTransferred(_newDID);
    }

    function getDIDFromHandle(
        string memory _handle
    ) public view returns (string memory) {
        bytes32 handleHash = keccak256(abi.encodePacked(_handle));
        string memory did = handleToDID[handleHash];
        if (bytes(did).length == 0) {
            revert HandleNotFound();
        }
        return did;
    }

    function getHandleFromDID(
        string memory _did
    ) public view returns (string memory) {
        bytes32 didHash = keccak256(abi.encodePacked(_did));
        string memory handle = didToHandle[didHash];
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
