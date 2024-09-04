// SPDX-License-Identifier: AGPL v3 or higher
pragma solidity ^0.8.0;

contract DelegateAnnouncer {
    event AnnounceDelegation(address indexed dao, address indexed delegate, bytes message);

    function announceDelegation(address dao, bytes calldata message) public {
        emit AnnounceDelegation(dao, msg.sender, message);
    }
}
