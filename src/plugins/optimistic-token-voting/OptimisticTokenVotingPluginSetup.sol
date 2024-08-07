// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.17;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {IVotesUpgradeable} from "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";

import {IDAO} from "@aragon/osx/core/dao/IDAO.sol";
import {DAO} from "@aragon/osx/core/dao/DAO.sol";
import {PermissionLib} from "@aragon/osx/core/permission/PermissionLib.sol";
import {PluginSetup, IPluginSetup} from "@aragon/osx/framework/plugin/setup/PluginSetup.sol";
import {GovernanceERC20} from "@aragon/osx/token/ERC20/governance/GovernanceERC20.sol";
import {GovernanceWrappedERC20} from "@aragon/osx/token/ERC20/governance/GovernanceWrappedERC20.sol";
import {IGovernanceWrappedERC20} from "@aragon/osx/token/ERC20/governance/IGovernanceWrappedERC20.sol";
import {OptimisticTokenVotingPlugin} from "./OptimisticTokenVotingPlugin.sol";

/// @title OptimisticTokenVotingPluginSetup
/// @author Aragon Association - 2022-2023
/// @notice The setup contract of the `OptimisticTokenVoting` plugin.
/// @custom:security-contact sirt@aragon.org
contract OptimisticTokenVotingPluginSetup is PluginSetup {
    using Address for address;
    using Clones for address;
    using ERC165Checker for address;

    /// @notice The address of the `OptimisticTokenVotingPlugin` base contract.
    OptimisticTokenVotingPlugin private immutable optimisticTokenVotingPluginBase;

    /// @notice The token settings struct.
    /// @param addr The voting token contract address.
    /// @param underlyingTotalSupply Total supply of underlying token in voting token.
    struct TokenSettings {
        address addr;
        uint256 underlyingTotalSupply;
    }

    /// @notice Thrown if token address is passed which is not a token.
    /// @param token The token address
    error TokenNotContract(address token);

    /// @notice Thrown if token address is not ERC20.
    /// @param token The token address
    error TokenNotERC20(address token);

    /// @notice Thrown if token address is not valid.
    /// @param token The token address
    error TokenNotValid(address token);

    /// @notice Thrown if passed helpers array is of wrong length.
    /// @param length The array length of passed helpers.
    error WrongHelpersArrayLength(uint256 length);

    /// @notice The contract constructor deploying the plugin implementation contract.
    constructor() {
        optimisticTokenVotingPluginBase = new OptimisticTokenVotingPlugin();
    }

    /// @inheritdoc IPluginSetup
    function prepareInstallation(address _dao, bytes calldata _installParameters)
        external
        returns (address plugin, PreparedSetupData memory preparedSetupData)
    {
        // Decode `_installParameters` to extract the params needed for deploying and initializing `OptimisticTokenVoting` plugin,
        // and the required helpers
        (
            OptimisticTokenVotingPlugin.OptimisticGovernanceSettings memory votingSettings,
            TokenSettings memory tokenSettings,
            address[] memory proposers
        ) = abi.decode(
            _installParameters, (OptimisticTokenVotingPlugin.OptimisticGovernanceSettings, TokenSettings, address[])
        );

        address token = tokenSettings.addr;

        if (!token.isContract()) {
            revert TokenNotContract(token);
        }

        if (!_isERC20(token)) {
            revert TokenNotERC20(token);
        }

        // [0] = IERC20Upgradeable, [1] = IVotesUpgradeable
        bool[] memory supportedIds = _getTokenInterfaceIds(token);
        if (!supportedIds[0] || !supportedIds[1]) {
            revert TokenNotValid(token);
        }

        // Prepare helpers.
        address[] memory helpers = new address[](1);

        helpers[0] = token;

        // Prepare and deploy plugin proxy.
        plugin = createERC1967Proxy(
            address(optimisticTokenVotingPluginBase),
            abi.encodeCall(
                OptimisticTokenVotingPlugin.initialize,
                (IDAO(_dao), votingSettings, IVotesUpgradeable(token), tokenSettings.underlyingTotalSupply)
            )
        );

        // Prepare permissions
        PermissionLib.MultiTargetPermission[] memory permissions =
            new PermissionLib.MultiTargetPermission[](3 + proposers.length);

        // Request the permissions to be granted

        // The DAO can update the plugin settings
        permissions[0] = PermissionLib.MultiTargetPermission({
            operation: PermissionLib.Operation.Grant,
            where: plugin,
            who: _dao,
            condition: PermissionLib.NO_CONDITION,
            permissionId: optimisticTokenVotingPluginBase.UPDATE_OPTIMISTIC_GOVERNANCE_SETTINGS_PERMISSION_ID()
        });

        // The DAO can upgrade the plugin implementation
        permissions[1] = PermissionLib.MultiTargetPermission({
            operation: PermissionLib.Operation.Grant,
            where: plugin,
            who: _dao,
            condition: PermissionLib.NO_CONDITION,
            permissionId: optimisticTokenVotingPluginBase.UPGRADE_PLUGIN_PERMISSION_ID()
        });

        // The plugin can make the DAO execute actions
        permissions[2] = PermissionLib.MultiTargetPermission({
            operation: PermissionLib.Operation.Grant,
            where: _dao,
            who: plugin,
            condition: PermissionLib.NO_CONDITION,
            permissionId: DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
        });

        // Proposers can create proposals
        for (uint256 i = 0; i < proposers.length;) {
            permissions[3 + i] = PermissionLib.MultiTargetPermission({
                operation: PermissionLib.Operation.Grant,
                where: plugin,
                who: proposers[i],
                condition: PermissionLib.NO_CONDITION,
                permissionId: optimisticTokenVotingPluginBase.PROPOSER_PERMISSION_ID()
            });

            unchecked {
                i++;
            }
        }

        preparedSetupData.helpers = helpers;
        preparedSetupData.permissions = permissions;
    }

    /// @inheritdoc IPluginSetup
    function prepareUninstallation(address _dao, SetupPayload calldata _payload)
        external
        view
        returns (PermissionLib.MultiTargetPermission[] memory permissions)
    {
        // Prepare permissions.
        permissions = new PermissionLib.MultiTargetPermission[](3);

        // Set permissions to be Revoked.
        permissions[0] = PermissionLib.MultiTargetPermission({
            operation: PermissionLib.Operation.Revoke,
            where: _payload.plugin,
            who: _dao,
            condition: PermissionLib.NO_CONDITION,
            permissionId: optimisticTokenVotingPluginBase.UPDATE_OPTIMISTIC_GOVERNANCE_SETTINGS_PERMISSION_ID()
        });

        permissions[1] = PermissionLib.MultiTargetPermission({
            operation: PermissionLib.Operation.Revoke,
            where: _payload.plugin,
            who: _dao,
            condition: PermissionLib.NO_CONDITION,
            permissionId: optimisticTokenVotingPluginBase.UPGRADE_PLUGIN_PERMISSION_ID()
        });

        permissions[2] = PermissionLib.MultiTargetPermission({
            operation: PermissionLib.Operation.Revoke,
            where: _dao,
            who: _payload.plugin,
            condition: PermissionLib.NO_CONDITION,
            permissionId: DAO(payable(_dao)).EXECUTE_PERMISSION_ID()
        });
    }

    /// @inheritdoc IPluginSetup
    function implementation() external view virtual override returns (address) {
        return address(optimisticTokenVotingPluginBase);
    }

    /// @notice Retrieves the interface identifiers supported by the token contract.
    /// @dev It is crucial to verify if the provided token address represents a valid contract before using the below.
    /// @param token The token address
    function _getTokenInterfaceIds(address token) private view returns (bool[] memory) {
        bytes4[] memory interfaceIds = new bytes4[](2);
        interfaceIds[0] = type(IERC20Upgradeable).interfaceId;
        interfaceIds[1] = type(IVotesUpgradeable).interfaceId;
        return token.getSupportedInterfaces(interfaceIds);
    }

    /// @notice Unsatisfiably determines if the contract is an ERC20 token.
    /// @dev It's important to first check whether token is a contract prior to this call.
    /// @param token The token address
    function _isERC20(address token) private view returns (bool) {
        (bool success, bytes memory data) =
            token.staticcall(abi.encodeCall(IERC20Upgradeable.balanceOf, (address(this))));
        return success && data.length == 0x20;
    }
}
