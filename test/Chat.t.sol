// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {ChatAppilcation} from "../src/ChatAppilcation.sol";
import {ENS} from "../src/ENS.sol";

contract Chat is Test {
    ChatAppilcation public chat;
    ENS public ens;

    address A = address(0xa);
    address B = address(0xb);

    string img = "img-url";
    bytes Name = abi.encodePacked("Okste");
    bytes Name2 = abi.encodePacked("Adekunle");
    bytes imgUrl = abi.encodePacked(string(img));

    function setUp() public {
        ens = new ENS();

        chat = new ChatAppilcation(address(ens));

        A = mkaddr("user a");
        B = mkaddr("user b");
    }

    function test_ensRegisteration() public {
        ens.registarUser(bytes32(Name), bytes32(imgUrl));
        assert(true);
    }

    function test_revertCase_manageAccount() public {
        vm.expectRevert("User does not exist");
        ens.manageAccount(bytes32(Name), bytes32(Name2), bytes32(imgUrl));
    }

    function test_changeOn_manageAccount() public {
        switchSigner(A);
        ens.registarUser(bytes32(Name), bytes32(imgUrl));
        ens.manageAccount(bytes32(Name), bytes32(Name2), bytes32(imgUrl));

        assertEq(ens.getUserByAddress(address(A)).name, bytes32(Name2));
    }

    function test_revertCase_getUserByName() public {
        ens.registarUser(bytes32(Name), bytes32(imgUrl));
        vm.expectRevert("User not found, check for any typo-error");
        ens.getUserByName(bytes32(Name2));
    }

    function test_UserByNameEqualGetUserAddress() public {
        ens.registarUser(bytes32(Name), bytes32(imgUrl));
        address account = ens.getUserByName(bytes32(Name)).account;

        assertEq(
            ens.getUserByAddress(account).name,
            ens.getUserByName(bytes32(Name)).name
        );
    }

    function test_chat_registeration() public {
        ens.registarUser(bytes32(Name), bytes32(imgUrl));
        chat.registeration(bytes32(Name));

        assert(true);
    }

    function test_chatRevertCase_registeration() public {
        ens.registarUser(bytes32(Name), bytes32(imgUrl));
        vm.expectRevert("Invalid ENS name, registeration unsuccessful");
        chat.registeration(bytes32(Name2));
    }

    function test_chatRevertCase2_registeration() public {
        switchSigner(A);
        ens.registarUser(bytes32(Name), bytes32(imgUrl));
        chat.registeration(bytes32(Name));
        switchSigner(B);
        vm.expectRevert("Username already exist");
        chat.registeration(bytes32(Name));
    }

    function test_chatRevertCase3_registeration() public {
        switchSigner(A);
        ens.registarUser(bytes32(Name), bytes32(imgUrl));
        chat.registeration(bytes32(Name));

        vm.expectRevert("User with this address already exist");
        chat.registeration(bytes32(Name));
    }

    function test_sendMessage() public {
        switchSigner(A);
        ens.registarUser(bytes32(Name), bytes32(imgUrl));
        chat.registeration(bytes32(Name));

        switchSigner(B);
        ens.registarUser(bytes32(Name2), bytes32(imgUrl));
        chat.registeration(bytes32(Name2));
        chat.sendMessage(bytes32(Name), "Hi");

        switchSigner(A);
        chat.sendMessage(bytes32(Name2), "Hello");

        chat.getChatHistory(bytes32(Name2));
        assertEq(chat.getChatHistory(bytes32(Name2))[0].sentMessage, "Hello");
        assertEq(chat.getChatHistory(bytes32(Name2))[0].receiveMessage, "Hi");
    }

    function mkaddr(string memory nam) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(nam))))
        );
        vm.label(addr, nam);
        return addr;
    }

    function switchSigner(address _newSigner) public {
        address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        if (msg.sender == foundrySigner) {
            vm.startPrank(_newSigner);
        } else {
            vm.stopPrank();
            vm.startPrank(_newSigner);
        }
    }
}
