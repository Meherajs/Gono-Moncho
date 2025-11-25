// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../tokens/CRED.sol";
import "./SANUB.sol";
import "./ReporterRegistry.sol";
import "../external/AIOracle.sol";
import "../external/ArweaveStorage.sol";

contract Verification {
    CRED public credToken;
    AIOracle public aiOracle;
    ArweaveStorage public arweave;
    ReporterRegistry public reporterRegistry;

    enum VerificationStatus {
        PENDING,
        AI_VERIFIED,
        HUMAN_VERIFIED,
        DISPUTED
    }

    struct NewsItem {
        address reporter;
        string arweaveHash;
        uint256[] analyzerScores;
        uint256[] verifierScores;
        VerificationStatus status;
        uint256 credibilityScore;
    }

    mapping(string => NewsItem) public newsItems;

    event NewsPublished(string indexed arweaveHash, address indexed reporter);
    event NewsVerified(string indexed arweaveHash, VerificationStatus status);

    constructor(
        address _credToken,
        address _aiOracle,
        address _arweave,
        address _reporterRegistry
    ) {
        credToken = CRED(_credToken);
        aiOracle = AIOracle(_aiOracle);
        arweave = ArweaveStorage(_arweave);
        reporterRegistry = ReporterRegistry(_reporterRegistry);
    }

    function publishNews(string memory contentHash) external {
        // Check if reporter is verified and can publish
        require(
            reporterRegistry.canPublish(msg.sender),
            "Not authorized to publish. Please register and get verified as a reporter."
        );

        // Store reference to Arweave content
        arweave.storeReference(contentHash, msg.sender);

        // Initialize news item
        newsItems[contentHash] = NewsItem({
            reporter: msg.sender,
            arweaveHash: contentHash,
            analyzerScores: new uint256[](0),
            verifierScores: new uint256[](0),
            status: VerificationStatus.PENDING,
            credibilityScore: 0
        });

        // Increment article count for reporter
        reporterRegistry.incrementArticleCount(msg.sender);

        emit NewsPublished(contentHash, msg.sender);
    }

    function requestAIVerification(string memory contentHash) external {
        require(newsItems[contentHash].reporter == msg.sender, "Not owner");
        aiOracle.requestAnalysis(contentHash);
    }

    function addVerifierScore(
        string memory contentHash,
        uint256 score
    ) external {
        // Check if user is authorized to verify
        require(
            reporterRegistry.canVerify(msg.sender),
            "Not authorized to verify. Please register as an analyzer or verifier."
        );

        NewsItem storage item = newsItems[contentHash];
        require(item.reporter != address(0), "News item does not exist");
        require(score <= 100, "Score must be between 0 and 100");

        item.verifierScores.push(score);
    }

    function finalizeVerification(string memory contentHash) external {
        NewsItem storage item = newsItems[contentHash];
        require(item.status == VerificationStatus.PENDING, "Already verified");

        // Calculate credibility using SANUB model
        uint256 belief = SANUB.calculateBelief(item.verifierScores);
        uint256 importance = SANUB.calculateImportance(
            item.verifierScores.length,
            credToken.totalSupply()
        );

        // Simplified credibility calculation
        item.credibilityScore = (belief * importance) / 1e18;
        item.status = VerificationStatus.HUMAN_VERIFIED;

        emit NewsVerified(contentHash, item.status);
    }
}
