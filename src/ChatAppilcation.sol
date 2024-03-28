// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IENS} from "./interface/IENS.sol";

contract ChatAppilcation {
    IENS ENS;

    struct Chat {
        bytes32 senderUsername;
        string sentMessage;
        string receiveMessage;
        uint timeStamp;
        bytes32 recieverUsername;
    }

    mapping(address => mapping(bytes32 => Chat[])) chats;
    mapping(address => mapping(address => string)) messages;

    mapping(address => bool) isMemberAddress;
    mapping(bytes32 => bool) isMemberName;

    IENS.User[] users;

    constructor(address _ensAddr) {
        ENS = IENS(_ensAddr);
    }

    event Registeration(address indexed sender, bytes32 indexed username);
    event MessageSent(
        bytes32 indexed sender,
        bytes32 indexed receiver,
        string message,
        bool,
        uint256 time
    );

    function registeration(bytes32 username) external returns (bool) {
        require(
            ENS.isRegistered(username),
            "Invalid ENS name, registeration unsuccessful"
        );

        require(
            !isMemberAddress[msg.sender],
            "User with this address already exist"
        );
        require(!isMemberName[username], "Username already exist");

        IENS.User memory user = ENS.getUserByName(username);
        users.push(user);

        isMemberAddress[msg.sender] = true;
        isMemberName[username] = true;

        emit Registeration(msg.sender, username);

        return true;
    }

    function sendMessage(
        bytes32 _receiverUsername,
        string memory _message
    ) external {
        require(
            isMemberAddress[msg.sender],
            "Register first before you can send message"
        );
        require(
            ENS.isRegistered(_receiverUsername),
            "Invalid ENS name,  receiver does not exist"
        );
        require(
            isMemberName[_receiverUsername],
            "Receiver is not a valid user"
        );

        IENS.User memory user = ENS.getUserByAddress(msg.sender);
        address receiver = ENS.getUserByName(_receiverUsername).account;

        require(bytes(_message).length > 0, "Message cannot be empty");

        messages[msg.sender][receiver] = _message;

        Chat memory newChat;
        newChat.senderUsername = user.name;
        newChat.sentMessage = messages[msg.sender][receiver];
        newChat.receiveMessage = messages[receiver][user.account];
        newChat.timeStamp = block.timestamp;
        newChat.recieverUsername = _receiverUsername;

        // Add the message to sender's chat history
        chats[msg.sender][_receiverUsername].push(newChat);

        emit MessageSent(
            user.name,
            _receiverUsername,
            _message,
            true,
            block.timestamp
        );
    }

    function getChatHistory(
        bytes32 receiver
    ) external view returns (Chat[] memory) {
        require(isMemberAddress[msg.sender], "Address not valid member");
        require(isMemberName[receiver], "Receiver is not a valid user");

        return chats[msg.sender][receiver];
    }

    function getAllUsers() external view returns (IENS.User[] memory) {
        return users;
    }

    function searchUserByAddress(
        address _account
    ) external view returns (IENS.User memory) {
        require(isMemberAddress[_account], "User address not registered");

        return ENS.getUserByAddress(_account);
    }

    function searchUserByUsername(
        bytes32 _username
    ) external view returns (IENS.User memory) {
        require(
            ENS.isRegistered(_username),
            "Invalid ENS name,  username does not exist"
        );
        require(isMemberName[_username], "Username is not a valid user");

        return ENS.getUserByName(_username);
    }
}
