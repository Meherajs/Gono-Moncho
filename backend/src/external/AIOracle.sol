// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * ChainlinkAIOracle - Decentralized AI Oracle for news credibility analysis
 *
 * Provides AI-powered initial analysis of news articles
 *
 * IMPORTANT: AI is NOT a "truth verifier" but an "analysis tool"
 * - Cross-checks with existing sources
 * - Verifies citations and sources
 * - Provides initial credibility score
 * - Results are CLEARLY TAGGED as AI analysis (subject to hallucination)
 * - Human verification is REQUIRED for final credibility
 *
 * NOTE: This is a simplified version for testing. Full Chainlink integration requires:
 * - Installing @chainlink/contracts package
 * - Configuring oracle nodes
 * - LINK token setup
 */
contract ChainlinkAIOracle is Ownable {
    struct AnalysisResult {
        uint256 credibilityScore; // 0-100
        uint256 timestamp;
        bool completed;
        string[] sourcesChecked;
        string[] citationsVerified;
        string analysisReport; // IPFS hash of detailed report
        bool aiHallucinationWarning; // Flag if AI shows signs of hallucination
    }

    // Mapping from content hash to analysis result
    mapping(string => AnalysisResult) public analyses;

    // Mapping from Chainlink request ID to content hash
    mapping(bytes32 => string) public requestIdToContentHash;

    // Oracle configuration
    address public oracle;
    bytes32 private jobId;
    uint256 private fee;

    // Minimum credibility threshold for auto-approval
    uint256 public minimumAutoApprovalScore = 85;

    // Maximum time to wait for AI response
    uint256 public maxResponseTime = 1 hours;

    // Events
    event AnalysisRequested(string indexed contentHash, bytes32 requestId);
    event AnalysisCompleted(
        string indexed contentHash,
        uint256 credibilityScore
    );
    event AnalysisFailed(string indexed contentHash, string reason);
    event AIHallucinationDetected(string indexed contentHash);

    /**
     * @notice Initialize the AI Oracle
     * @param _oracle Address of oracle node
     * @param _jobId Oracle job ID for AI analysis
     */
    constructor(address _oracle, bytes32 _jobId) Ownable(msg.sender) {
        oracle = _oracle;
        jobId = _jobId;
        fee = 0.1 * 10 ** 18; // 0.1 LINK equivalent
    }

    /**
     * @notice Request AI analysis for content
     * @param contentHash Hash of the content to analyze
     * @param contentUrl URL where content can be accessed (IPFS/Arweave)
     * @return requestId Chainlink request ID
     */
    function requestAnalysis(
        string memory contentHash,
        string memory contentUrl
    ) external returns (bytes32 requestId) {
        require(!analyses[contentHash].completed, "Analysis already completed");

        // Generate request ID
        requestId = keccak256(
            abi.encodePacked(contentHash, contentUrl, block.timestamp)
        );

        requestIdToContentHash[requestId] = contentHash;

        emit AnalysisRequested(contentHash, requestId);

        return requestId;
    }

    /**
     * @notice Callback function for oracle to fulfill analysis request
     * @param _requestId Oracle request ID
     * @param credibilityScore AI-determined credibility score (0-100)
     * @param sourcesChecked List of sources the AI verified
     * @param citationsVerified List of citations the AI checked
     * @param reportHash IPFS hash of detailed analysis report
     * @param hallucinationWarning Whether AI detected potential hallucination in content
     */
    function fulfillAnalysis(
        bytes32 _requestId,
        uint256 credibilityScore,
        string[] memory sourcesChecked,
        string[] memory citationsVerified,
        string memory reportHash,
        bool hallucinationWarning
    ) public {
        require(msg.sender == oracle, "Only oracle can fulfill");
        string memory contentHash = requestIdToContentHash[_requestId];

        require(bytes(contentHash).length > 0, "Invalid request ID");

        // Store analysis results
        analyses[contentHash] = AnalysisResult({
            credibilityScore: credibilityScore,
            timestamp: block.timestamp,
            completed: true,
            sourcesChecked: sourcesChecked,
            citationsVerified: citationsVerified,
            analysisReport: reportHash,
            aiHallucinationWarning: hallucinationWarning
        });

        if (hallucinationWarning) {
            emit AIHallucinationDetected(contentHash);
        }

        emit AnalysisCompleted(contentHash, credibilityScore);

        // Clean up request mapping
        delete requestIdToContentHash[_requestId];
    }

    /**
     * @notice Get analysis result for content
     * @param contentHash Content hash to query
     * @return score Credibility score
     * @return completed Whether analysis is complete
     * @return report IPFS hash of detailed report
     */
    function getAnalysis(
        string memory contentHash
    )
        external
        view
        returns (
            uint256 score,
            bool completed,
            string memory report,
            bool aiWarning
        )
    {
        AnalysisResult memory result = analyses[contentHash];
        return (
            result.credibilityScore,
            result.completed,
            result.analysisReport,
            result.aiHallucinationWarning
        );
    }

    /**
     * @notice Check if content can be auto-approved based on AI score
     * @param contentHash Content hash to check
     */
    function canAutoApprove(
        string memory contentHash
    ) external view returns (bool) {
        AnalysisResult memory result = analyses[contentHash];

        if (!result.completed) {
            return false;
        }

        if (result.aiHallucinationWarning) {
            return false; // Never auto-approve if hallucination detected
        }

        return result.credibilityScore >= minimumAutoApprovalScore;
    }

    /**
     * @notice Get detailed analysis breakdown
     * @param contentHash Content hash to query
     */
    function getDetailedAnalysis(
        string memory contentHash
    )
        external
        view
        returns (
            uint256 score,
            uint256 timestamp,
            string[] memory sources,
            string[] memory citations,
            string memory report
        )
    {
        AnalysisResult memory result = analyses[contentHash];
        return (
            result.credibilityScore,
            result.timestamp,
            result.sourcesChecked,
            result.citationsVerified,
            result.analysisReport
        );
    }

    /**
     * @notice Update minimum auto-approval score
     * @param newScore New minimum score (0-100)
     */
    function updateMinimumScore(uint256 newScore) external onlyOwner {
        require(newScore <= 100, "Score too high");
        minimumAutoApprovalScore = newScore;
    }

    /**
     * @notice Update Chainlink job ID
     * @param newJobId New job ID
     */
    function updateJobId(bytes32 newJobId) external onlyOwner {
        jobId = newJobId;
    }

    /**
     * @notice Update Chainlink fee
     * @param newFee New fee in LINK
     */
    function updateFee(uint256 newFee) external onlyOwner {
        fee = newFee;
    }

    /**
     * @notice Withdraw funds from contract
     */
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * @notice Update oracle address
     */
    function updateOracle(address newOracle) external onlyOwner {
        require(newOracle != address(0), "Invalid oracle");
        oracle = newOracle;
    }
}

/**
 * @notice Legacy interface for backwards compatibility
 */
interface AIOracle {
    function requestAnalysis(
        string memory contentHash,
        string memory contentUrl
    ) external returns (bytes32);

    function getAnalysis(
        string memory contentHash
    ) external view returns (uint256, bool, string memory, bool);
}
