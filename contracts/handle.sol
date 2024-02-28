pragma solidity ^0.8.0; // Specify Solidity version

contract HandleRegistry {

    // Structure to store a handle and its owner
    struct Handle {
        string name;
        address owner;
    }

    // Mapping to store handles (handle name => handle struct)
    mapping(string => Handle) public handles;

    // Event to signal when a handle is registered
    event HandleRegistered(string name, address owner);

    // Function to register a handle (only if it isn't already taken)
    function registerHandle(string memory _name) public {
        require(handles[_name].owner == address(0), "Handle already exists"); // Check for availability

        // Create a new handle and assign it to the sender
        handles[_name] = Handle(_name, msg.sender);

        emit HandleRegistered(_name, msg.sender); // Emit the event
    }

    // Function to transfer handle ownership
    function transferHandle(string memory _name, address _newOwner) public {
        // Ensure the caller is the current owner
        require(handles[_name].owner == msg.sender, "Only the owner can transfer the handle");

        // Update the handle's owner
        handles[_name].owner = _newOwner; 

        // Optionally: Emit a HandleTransferred event
    }

    // Function to get the owner of a handle
    function getHandleOwner(string memory _name) public view returns (address) {
        return handles[_name].owner;
    }

}