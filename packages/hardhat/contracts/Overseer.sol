pragma solidity >=0.8.0 <0.9.0;

import "@gnosis.pm/safe-contracts/contracts/base/ModuleManager.sol";
import "@gnosis.pm/safe-contracts/contracts/common/Singleton.sol";

/// The address must be valid.
/// @param _address - the provided address
error InvalidAddress(address _address);

/// Must be overseer
/// @param _address - the provided address
error MustBeOverseer(address _address);

/// Sender must be authorized by the comission
/// @param sender - the provided address
error MustBeManager(address sender);

/// The module must have been enabled
error ModuleMustBeEnabled();

/// The overseer must not be the previous one
error OverseerMustNotBePreviousOne();

/// @title Overseer - A smart contract that allows a single trusted person to change the configuration of a Comission (Safe)
/// @author Leonardo Cardoso - <leonardo.t.cardoso@hotmail.com>
contract Overseer is Singleton {
    address internal manager;
    address internal overseer;

    /// Setup the Overseer. Must be only invoked once
    /// @param _overseer - the required amount of approvals which may be required to change upon member adition
    function setup(address _overseer) public {
        if (manager != address(0)) revert("Manager has already been set");
        requireValidAddress(_overseer);

        overseer = _overseer;
        manager = msg.sender;
    }

    /// Add a member to the comission
    /// @param _member - the new member's address
    /// @param _threshold - the required amount of approvals which may be required to change upon member adition
    function addMember(address _member, uint256 _threshold) public returns (bool success) {
        requireModuleEnabled();
        requireOverseer();

        bytes memory data = abi.encodeWithSignature(
            "addOwnerWithThreshold(address,uint256)",
            _member,
            _threshold
        );

        success = ModuleManager(manager).execTransactionFromModule(manager, 0, data, Enum.Operation.Call);
    }

    /// Remove a member to the comission
    /// @param _prevMember - the previous member's address, should follow Safe contract owners sequence obtained through getOwners
    /// @param _member - the member's address that should be removed from the comission
    /// @param _threshold - the required amount of approvals
    function removeMember(address _prevMember, address _member, uint256 _threshold) public returns (bool success) {
        requireModuleEnabled();
        requireOverseer();

        bytes memory data = abi.encodeWithSignature(
            "removeOwner(address,address,uint256)",
            _prevMember,
            _member,
            _threshold
        );

        success = ModuleManager(manager).execTransactionFromModule(manager, 0, data, Enum.Operation.Call);
    }

    /// Change the required approvals to run operations
    /// @param _threshold - the required amount of approvals
    function changeMinimumQuorum(uint256 _threshold) public returns (bool success) {
        requireModuleEnabled();
        requireOverseer();

        bytes memory data = abi.encodeWithSignature(
            "swapOwner(uint256)",
            _threshold
        );

        success = ModuleManager(manager).execTransactionFromModule(manager, 0, data, Enum.Operation.Call);
    }

    /// Promote a new overseer.
    /// @param _overseer - the new overseers address
    function promoteOverseer(address _overseer) public  {
        requireModuleEnabled();
        requireComissionAuthorized();
        requireValidAddress(_overseer);
        requireNewOverseer(_overseer);

        overseer = _overseer;
    }

    function requireModuleEnabled() internal view {
        if (!ModuleManager(manager).isModuleEnabled(address(this))) revert ModuleMustBeEnabled();
    }

    function requireComissionAuthorized() internal view {
        if (msg.sender != manager) revert MustBeManager(msg.sender);
    }

    function requireOverseer() internal view {
        if (msg.sender != overseer) revert MustBeOverseer(msg.sender);
    }

    function requireNewOverseer(address _overseer) internal view {
        if (_overseer == overseer) revert OverseerMustNotBePreviousOne();
    }

    function requireValidAddress(address _address) internal pure {
        if (_address == address(0) || _address == address(0x1)) revert InvalidAddress(_address);
    }
}