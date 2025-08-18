// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Gono Moncho Custom Errors
 * @dev Gas-efficient error definitions for revert scenarios
 */
library Errors {
    // Access Control (0x1..)
    error Unauthorized(address caller);
    error NotReporter(address caller);
    error NotVerifier(address caller);
    error NotCouncilMember(address caller);
    error NotNewsDAOMember(address caller);
    error ContractPaused();

    // Token Operations (0x2..)
    error InsufficientStake(uint256 required, uint256 provided);
    error SlashAmountExceedsStake(uint256 stake, uint256 slashAmount);
    error TransferDisabled(address token);
    error ZeroAddressReceiver();
    error BurnDisabled();
    error MintDisabled();

    // Governance (0x3..)
    error ProposalNotFound(uint256 proposalId);
    error VotingClosed(uint256 proposalId);
    error AlreadyVoted(uint256 proposalId, address voter);
    error InsufficientVotingPower(uint256 required, uint256 held);
    error DelegationDisabled();
    error ExecutionWindowExpired(uint256 deadline);
    error InvalidQuorum(uint256 required, uint256 achieved);
    error UnmetProposalThreshold();

    // Verification System (0x4..)
    error NewsItemNotFound(uint256 itemId);
    error AlreadyVerified(uint256 itemId, address verifier);
    error VerificationClosed(uint256 itemId);
    error InvalidEvidence();
    error InvalidAIResponse();
    error CouncilReviewRequired(uint256 itemId);
    error ProofOfHumanityFailed(address user);

    // Parameter Validation (0x5..)
    error ZeroAmount();
    error ArrayLengthMismatch();
    error InvalidDeadline(uint256 deadline);
    error InvalidFeePercentage(uint256 percentage);
    error InvalidTokenAddress();
    error InvalidDuration(uint256 min, uint256 max, uint256 provided);

    // Treasury/DAO (0x6..)
    error InsufficientFunds(uint256 balance, uint256 required);
    error WithdrawalFailed(address recipient);
    error InvalidRevenueSplit(uint256 totalPercentage);
    error GrantApplicationClosed();
    error InvalidGrantRecipient(address recipient);

    // Storage (0x7..)
    error ArweaveUploadFailed();
    error PermanentStorageLocked();
    error InvalidContentHash(bytes32 hash);

    // Oracle (0x8..)
    error OracleResponseInvalid();
    error ChainlinkNotResponding();
    error AIValidationTimeout();

    // Emergency (0xF..)
    error EmergencyStopActive();
}
