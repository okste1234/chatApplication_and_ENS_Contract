// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ENS {
    struct User {
        address account;
        bytes32 name;
        bytes32 image;
    }
    mapping(address => User) user;
    mapping(bytes32 => User) userB;
    mapping(bytes32 => bool) public isRegistered;

    event Registeration(
        address indexed sender,
        bytes32 indexed username,
        bytes32 image
    );
    event ManageAccount(bytes32 indexed username, bytes32 image, bool);

    function registarUser(
        bytes32 _name,
        bytes32 _img
    ) public returns (bool successful) {
        require(!isRegistered[_name], "username already exist");

        User storage acct = user[msg.sender];
        User storage mapName = userB[_name];

        acct.name = _name;
        acct.account = msg.sender;
        acct.image = _img;

        mapName.name = _name;
        mapName.account = msg.sender;
        mapName.image = _img;

        isRegistered[_name] = true;
        successful = true;

        emit Registeration(msg.sender, _name, _img);
    }

    function manageAccount(
        bytes32 _OldName,
        bytes32 _newName,
        bytes32 _img
    ) external {
        require(isRegistered[_OldName], "User does not exist");

        User storage mapName = userB[_newName];
        User storage acct = user[msg.sender];
        require(msg.sender == acct.account, "Not your account");

        acct.name = _newName;
        acct.image = _img;
        acct.account = msg.sender;

        mapName.name = _newName;
        mapName.image = _img;
        mapName.account = msg.sender;

        emit ManageAccount(_newName, _img, true);
    }

    function getUserByName(bytes32 _name) public view returns (User memory) {
        require(
            isRegistered[_name],
            "User not found, check for any typo-error"
        );
        User memory mapName = userB[_name];

        return mapName;
    }

    function getUserByAddress(
        address account
    ) public view returns (User memory) {
        require(account != address(0), "No zero address call");
        User memory acct = user[account];

        return acct;
    }
}
