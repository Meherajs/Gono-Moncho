// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {GovernorTimelockControl} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";

import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

/// @title MonchoGovernor
/// @notice DAO Governor for Gono Moncho ecosystem
contract MonchoGovernor is
    Governor,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    /// @notice Create the Moncho Governor
    /// @param token The NEWS governance token (ERC20Votes)
    /// @param timelock The timelock controller for queued execution
    constructor(
        ERC20Votes token,
        TimelockController timelock
    )
        Governor("MonchoGovernor") // DAO name
        GovernorVotes(token) // Voting power = NEWS balance
        GovernorVotesQuorumFraction(10) // 10% quorum
        GovernorTimelockControl(timelock) // Timelock for execution
    {}

    /// @notice Voting delay before proposals can be voted on
    function votingDelay() public pure override returns (uint256) {
        return 1; // 1 block (adjust as needed)
    }

    /// @notice Voting period for proposals
    function votingPeriod() public pure override returns (uint256) {
        return 45818; // ~1 week in blocks (Ethereum: 13s blocks)
    }

    /// @notice Proposal threshold (min NEWS required to create proposal)
    function proposalThreshold() public pure override returns (uint256) {
        return 1000e18; // must hold 1000 NEWS
    }

    // ---- Required overrides ---- //

    function quorum(
        uint256 blockNumber
    )
        public
        view
        override(Governor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function state(
        uint256 proposalId
    )
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public virtual override(Governor) returns (uint256) {
        return super.propose(targets, values, calldatas, description);
    }

    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        virtual
        override(Governor, GovernorTimelockControl)
        returns (uint48)
    {
        return
            super._queueOperations(
                proposalId,
                targets,
                values,
                calldatas,
                descriptionHash
            );
    }

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual override(Governor, GovernorTimelockControl) {
        super._executeOperations(
            proposalId,
            targets,
            values,
            calldatas,
            descriptionHash
        );
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        virtual
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        virtual
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function proposalNeedsQueuing(
        uint256 proposalId
    )
        public
        view
        virtual
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(Governor) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
