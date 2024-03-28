// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IENS {
    struct User {
        address account;
        bytes32 name;
        bytes32 image;
    }

    function registarUser(
        bytes32 _name,
        bytes32 _img
    ) external returns (bool successful);

    function getUserByName(bytes32 _name) external view returns (User memory);

    function getUserByAddress(
        address account
    ) external view returns (User memory);

    function isRegistered(bytes32 _name) external view returns (bool);
}
