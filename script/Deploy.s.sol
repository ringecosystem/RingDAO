// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

import {DAO, DAOFactory} from "@aragon/osx/framework/dao/DAOFactory.sol";
import {PluginRepoFactory} from "@aragon/osx/framework/plugin/repo/PluginRepoFactory.sol";
import {PluginRepo} from "@aragon/osx/framework/plugin/repo/PluginRepo.sol";
import {hashHelpers, PluginSetupRef} from "@aragon/osx/framework/plugin/setup/PluginSetupProcessorHelpers.sol";
import {MajorityVotingBase} from "@aragon/osx/plugins/governance/majority-voting/MajorityVotingBase.sol";

import {TokenVotingPluginSetup} from "../src/plugins/token-voting/TokenVotingPluginSetup.sol";
import {DelegationWall} from "../src/DelegationWall.sol";

contract Deploy is Script {
    address gRING = 0xd677D6461870DD88B915EBa76954D1a15114B42d;
    address maintainer = 0x0f14341A7f464320319025540E8Fe48Ad0fe5aec;

    address pluginRepoFactory;
    DAOFactory daoFactory;
    address[] pluginAddress;

    DelegationWall delegationWall;
    TokenVotingPluginSetup tokenVotingPluginSetup;
    PluginRepo tokenVotingPluginRepo;
    DAO ringDAO;

    function setUp() public {
        pluginRepoFactory = vm.envAddress("PLUGIN_REPO_FACTORY");
        daoFactory = DAOFactory(vm.envAddress("DAO_FACTORY"));
    }

    function run() public {
        vm.startBroadcast();

        require(msg.sender == maintainer, "!maintainer");

        console2.log("Chain ID:", block.chainid);
        console2.log("Deploying from:", msg.sender);

        delegationWall = new DelegationWall();

        // 1. Deploying the Plugin Setup
        deployPluginSetup();

        // 2. Publishing it in the Aragon OSx Protocol
        deployPluginRepo();

        // 3. Defining the DAO Settings
        DAOFactory.DAOSettings memory daoSettings = getDAOSettings();

        // 4. Defining the plugin settings
        DAOFactory.PluginSettings[] memory pluginSettings = getPluginSettings();

        // 5. Deploying the DAO
        vm.recordLogs();
        ringDAO = daoFactory.createDao(daoSettings, pluginSettings);

        // 6. Getting the Plugin Address
        Vm.Log[] memory logEntries = vm.getRecordedLogs();

        for (uint256 i = 0; i < logEntries.length; i++) {
            if (logEntries[i].topics[0] == keccak256("InstallationApplied(address,address,bytes32,bytes32)")) {
                pluginAddress.push(address(uint160(uint256(logEntries[i].topics[2]))));
            }
        }

        vm.stopBroadcast();

        // 7. Logging the resulting addresses
        console2.log("Delegation Wall: ", address(delegationWall));
        console2.log("TokenVoting Plugin Setup: ", address(tokenVotingPluginSetup));
        console2.log("TokenVoting Plugin Repo: ", address(tokenVotingPluginRepo));
        console2.log("Ring DAO: ", address(ringDAO));
        console2.log("Installed Plugins: ");
        for (uint256 i = 0; i < pluginAddress.length; i++) {
            console2.log("- ", pluginAddress[i]);
        }
    }

    function getMinVotingPower() public view returns (uint256) {
        if (block.chainid == 701) {
            return 400e18;
        } else if (block.chainid == 44) {
            revert("TODO");
        } else if (block.chainid == 46) {
            return 40000000e18;
        }
    }

    function deployPluginSetup() public {
        uint256 minVotingPower = getMinVotingPower();
        tokenVotingPluginSetup = new TokenVotingPluginSetup(minVotingPower);
    }

    function deployPluginRepo() public {
        tokenVotingPluginRepo = PluginRepoFactory(pluginRepoFactory).createPluginRepoWithFirstVersion(
            string.concat("ringdao-token-voting-", vm.toString(block.timestamp)),
            address(tokenVotingPluginSetup),
            maintainer,
            hex"12", // TODO: Give these actual values on prod
            hex"34"
        );
    }

    function getDAOSettings() public view returns (DAOFactory.DAOSettings memory) {
        return DAOFactory.DAOSettings(address(0), "", string.concat("governance-", vm.toString(block.timestamp)), "");
    }

    function getPluginSettings() public view returns (DAOFactory.PluginSettings[] memory pluginSettings) {
        pluginSettings = new DAOFactory.PluginSettings[](1);
        pluginSettings[0] = getTokenVotingPluginSetting();
    }

    function getTokenVotingPluginSetting() public view returns (DAOFactory.PluginSettings memory) {
        bytes memory pluginSettingsData = abi.encode(
            MajorityVotingBase.VotingSettings({
                votingMode: MajorityVotingBase.VotingMode.Standard,
                supportThreshold: 500_000, // 50%
                minParticipation: 1, // 0.0001%
                minDuration: 60 minutes,
                minProposerVotingPower: 1e18
            }),
            TokenVotingPluginSetup.TokenSettings({addr: gRING})
        );
        PluginRepo.Tag memory tag = PluginRepo.Tag(1, 1);
        return DAOFactory.PluginSettings(PluginSetupRef(tag, tokenVotingPluginRepo), pluginSettingsData);
    }
}
