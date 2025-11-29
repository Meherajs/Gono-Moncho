// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ProofOfHumanity
 * @notice Privacy-preserving Proof-of-Humanity protocol using social graph verification
 * @dev Implements BrightID-style verification without biometric data collection
 *
 * Critical for protecting journalists in oppressive regimes while preventing Sybil attacks.
 * Uses decentralized social graph analysis instead of biometric data.
 */
contract ProofOfHumanity is Ownable {
    // Verification status for each address
    enum VerificationStatus {
        NONE,
        PENDING,
        VERIFIED,
        FLAGGED,
        BANNED
    }

    struct HumanityProof {
        VerificationStatus status;
        uint256 verifiedAt;
        uint256 lastUpdateAt;
        bytes32 contextHash; // Hash of off-chain verification context
        uint8 confidenceScore; // 0-100, higher = more confident
        address[] socialConnections;
        bool isUnique; // Confirmed as unique human
    }

    // Mapping from address to humanity proof
    mapping(address => HumanityProof) public proofs;

    // Trusted verifiers (initially centralized, moves to DAO)
    mapping(address => bool) public trustedVerifiers;

    // BrightID node addresses (decentralized verification network)
    mapping(address => bool) public brightIDNodes;

    // Minimum confidence score to be considered verified
    uint8 public minimumConfidenceScore = 70;

    // Verification expiry (humans must re-verify periodically)
    uint256 public verificationExpiry = 365 days;

    // Events
    event HumanityVerified(address indexed human, uint8 confidenceScore);
    event VerificationUpdated(address indexed human, VerificationStatus status);
    event SocialConnectionAdded(
        address indexed human,
        address indexed connection
    );
    event VerifierAdded(address indexed verifier);
    event VerifierRemoved(address indexed verifier);
    event SybilDetected(address indexed suspicious, string reason);

    constructor(address initialOwner) Ownable(initialOwner) {
        trustedVerifiers[initialOwner] = true;
    }

    /**
     * @notice Submit proof of humanity using BrightID or similar verification
     * @param contextHash Hash of off-chain verification data (for privacy)
     * @param confidenceScore Confidence score from verification network (0-100)
     * @param socialConnections List of verified social connections
     */
    function submitProof(
        bytes32 contextHash,
        uint8 confidenceScore,
        address[] calldata socialConnections
    ) external {
        require(confidenceScore <= 100, "Invalid confidence score");
        require(
            proofs[msg.sender].status != VerificationStatus.BANNED,
            "Address banned"
        );

        proofs[msg.sender] = HumanityProof({
            status: confidenceScore >= minimumConfidenceScore
                ? VerificationStatus.VERIFIED
                : VerificationStatus.PENDING,
            verifiedAt: confidenceScore >= minimumConfidenceScore
                ? block.timestamp
                : 0,
            lastUpdateAt: block.timestamp,
            contextHash: contextHash,
            confidenceScore: confidenceScore,
            socialConnections: socialConnections,
            isUnique: false // Will be set by verifier
        });

        if (confidenceScore >= minimumConfidenceScore) {
            emit HumanityVerified(msg.sender, confidenceScore);
        }
    }

    /**
     * @notice Verify humanity proof by trusted verifier or BrightID node
     * @param human Address to verify
     * @param isUnique Whether this is confirmed as a unique human
     */
    function verifyHuman(address human, bool isUnique) external {
        require(
            trustedVerifiers[msg.sender] || brightIDNodes[msg.sender],
            "Not authorized verifier"
        );

        HumanityProof storage proof = proofs[human];
        require(proof.lastUpdateAt > 0, "No proof submitted");
        require(
            proof.confidenceScore >= minimumConfidenceScore,
            "Confidence too low"
        );

        proof.status = VerificationStatus.VERIFIED;
        proof.verifiedAt = block.timestamp;
        proof.isUnique = isUnique;

        emit VerificationUpdated(human, VerificationStatus.VERIFIED);
    }

    /**
     * @notice Flag suspicious activity (potential Sybil)
     * @param suspicious Address showing suspicious behavior
     * @param reason Description of suspicious activity
     */
    function flagSuspicious(
        address suspicious,
        string calldata reason
    ) external {
        require(trustedVerifiers[msg.sender], "Not authorized");

        proofs[suspicious].status = VerificationStatus.FLAGGED;
        proofs[suspicious].lastUpdateAt = block.timestamp;

        emit SybilDetected(suspicious, reason);
        emit VerificationUpdated(suspicious, VerificationStatus.FLAGGED);
    }

    /**
     * @notice Ban address after confirmed Sybil attack
     * @param attacker Address to ban
     */
    function banAddress(address attacker) external onlyOwner {
        proofs[attacker].status = VerificationStatus.BANNED;
        proofs[attacker].lastUpdateAt = block.timestamp;

        emit VerificationUpdated(attacker, VerificationStatus.BANNED);
    }

    /**
     * @notice Add social connection to strengthen proof
     * @param connection Verified social connection
     */
    function addSocialConnection(address connection) external {
        require(isVerified(connection), "Connection not verified");
        require(isVerified(msg.sender), "Caller not verified");

        proofs[msg.sender].socialConnections.push(connection);
        proofs[msg.sender].lastUpdateAt = block.timestamp;

        emit SocialConnectionAdded(msg.sender, connection);
    }

    /**
     * @notice Check if an address is verified as human
     * @param user Address to check
     * @return bool Whether the address is verified and not expired
     */
    function isVerified(address user) public view returns (bool) {
        HumanityProof memory proof = proofs[user];

        if (proof.status != VerificationStatus.VERIFIED) {
            return false;
        }

        // Check if verification has expired
        if (block.timestamp - proof.verifiedAt > verificationExpiry) {
            return false;
        }

        return proof.isUnique;
    }

    /**
     * @notice Get verification details for an address
     * @param user Address to query
     */
    function getProof(
        address user
    )
        external
        view
        returns (
            VerificationStatus status,
            uint256 verifiedAt,
            uint8 confidenceScore,
            bool isUnique,
            uint256 connectionCount
        )
    {
        HumanityProof memory proof = proofs[user];
        return (
            proof.status,
            proof.verifiedAt,
            proof.confidenceScore,
            proof.isUnique,
            proof.socialConnections.length
        );
    }

    /**
     * @notice Add trusted verifier
     * @param verifier Address to add
     */
    function addVerifier(address verifier) external onlyOwner {
        trustedVerifiers[verifier] = true;
        emit VerifierAdded(verifier);
    }

    /**
     * @notice Remove trusted verifier
     * @param verifier Address to remove
     */
    function removeVerifier(address verifier) external onlyOwner {
        trustedVerifiers[verifier] = false;
        emit VerifierRemoved(verifier);
    }

    /**
     * @notice Add BrightID node
     * @param node BrightID node address
     */
    function addBrightIDNode(address node) external onlyOwner {
        brightIDNodes[node] = true;
    }

    /**
     * @notice Remove BrightID node
     * @param node BrightID node address
     */
    function removeBrightIDNode(address node) external onlyOwner {
        brightIDNodes[node] = false;
    }

    /**
     * @notice Update minimum confidence score
     * @param newScore New minimum score (0-100)
     */
    function updateMinimumConfidence(uint8 newScore) external onlyOwner {
        require(newScore <= 100, "Invalid score");
        minimumConfidenceScore = newScore;
    }

    /**
     * @notice Update verification expiry period
     * @param newExpiry New expiry in seconds
     */
    function updateVerificationExpiry(uint256 newExpiry) external onlyOwner {
        require(newExpiry >= 30 days, "Expiry too short");
        verificationExpiry = newExpiry;
    }

    /**
     * @notice Get social graph metrics for analysis
     * @param user Address to analyze
     * @return connections Number of social connections
     * @return avgConfidence Average confidence of connections
     */
    function getSocialMetrics(
        address user
    ) external view returns (uint256 connections, uint256 avgConfidence) {
        HumanityProof memory proof = proofs[user];
        connections = proof.socialConnections.length;

        if (connections == 0) {
            return (0, 0);
        }

        uint256 totalConfidence = 0;
        for (uint i = 0; i < connections; i++) {
            totalConfidence += proofs[proof.socialConnections[i]]
                .confidenceScore;
        }

        avgConfidence = totalConfidence / connections;
        return (connections, avgConfidence);
    }
}
