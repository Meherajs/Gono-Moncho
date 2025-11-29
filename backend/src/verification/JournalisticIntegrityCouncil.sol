// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../tokens/CRED.sol";

/**
 * @title JournalisticIntegrityCouncil
 * @notice Expert council for final verification of high-impact or contentious news stories
 * @dev Provides human-in-the-loop oversight that technology alone cannot provide
 *
 * The Council consists of:
 * - Credentialed journalists with proven track records
 * - Academic experts in relevant fields
 * - Subject-matter experts for specialized topics
 * - Compensated from the DAO treasury for their work
 */
contract JournalisticIntegrityCouncil is AccessControl {
    bytes32 public constant COUNCIL_MEMBER = keccak256("COUNCIL_MEMBER");
    bytes32 public constant COUNCIL_ADMIN = keccak256("COUNCIL_ADMIN");

    CRED public immutable credToken;

    enum ReviewStatus {
        PENDING,
        IN_REVIEW,
        APPROVED,
        REJECTED,
        DISPUTED,
        REQUIRES_REVISION
    }

    struct CouncilMember {
        address memberAddress;
        string credentials; // IPFS hash of credentials
        string specialty; // Area of expertise
        uint256 joinedAt;
        uint256 reviewsCompleted;
        uint256 accuracyScore; // Track accuracy of past reviews
        bool isActive;
    }

    struct NewsReview {
        string contentHash;
        ReviewStatus status;
        uint256 requestedAt;
        uint256 completedAt;
        address[] assignedMembers;
        mapping(address => bool) hasVoted;
        mapping(address => bool) voteDecision; // true = approve, false = reject
        uint256 approvalsCount;
        uint256 rejectionsCount;
        string finalReport; // IPFS hash of detailed review report
        uint256 compensationPaid;
    }

    // Mapping from content hash to review
    mapping(string => NewsReview) public reviews;

    // Mapping from address to council member
    mapping(address => CouncilMember) public members;

    // Array of all member addresses
    address[] public memberAddresses;

    // Treasury for compensation
    address public treasuryAddress;

    // Compensation per review (in wei)
    uint256 public reviewCompensation = 0.1 ether;

    // Minimum votes required for decision
    uint256 public quorumSize = 3;

    // Minimum approval percentage (in basis points, 6700 = 67%)
    uint256 public approvalThreshold = 6700;

    // Events
    event MemberAdded(
        address indexed member,
        string credentials,
        string specialty
    );
    event MemberRemoved(address indexed member);
    event ReviewRequested(
        string indexed contentHash,
        address indexed requester
    );
    event MemberAssigned(string indexed contentHash, address indexed member);
    event VoteCast(
        string indexed contentHash,
        address indexed member,
        bool approved
    );
    event ReviewCompleted(string indexed contentHash, ReviewStatus finalStatus);
    event CompensationPaid(address indexed member, uint256 amount);

    constructor(address _credToken, address _treasury, address admin) {
        credToken = CRED(_credToken);
        treasuryAddress = _treasury;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(COUNCIL_ADMIN, admin);
    }

    /**
     * @notice Add a new council member
     * @param memberAddress Address of the member
     * @param credentials IPFS hash of credentials and proof of expertise
     * @param specialty Area of expertise (e.g., "Politics", "Science", "Economics")
     */
    function addMember(
        address memberAddress,
        string calldata credentials,
        string calldata specialty
    ) external onlyRole(COUNCIL_ADMIN) {
        require(memberAddress != address(0), "Invalid address");
        require(!members[memberAddress].isActive, "Already a member");

        members[memberAddress] = CouncilMember({
            memberAddress: memberAddress,
            credentials: credentials,
            specialty: specialty,
            joinedAt: block.timestamp,
            reviewsCompleted: 0,
            accuracyScore: 100, // Start at 100%
            isActive: true
        });

        memberAddresses.push(memberAddress);
        _grantRole(COUNCIL_MEMBER, memberAddress);

        emit MemberAdded(memberAddress, credentials, specialty);
    }

    /**
     * @notice Remove a council member
     * @param memberAddress Address to remove
     */
    function removeMember(
        address memberAddress
    ) external onlyRole(COUNCIL_ADMIN) {
        require(members[memberAddress].isActive, "Not an active member");

        members[memberAddress].isActive = false;
        _revokeRole(COUNCIL_MEMBER, memberAddress);

        emit MemberRemoved(memberAddress);
    }

    /**
     * @notice Request council review for high-impact news
     * @param contentHash Hash of the content to review
     */
    function requestReview(
        string calldata contentHash
    ) external returns (bool) {
        NewsReview storage review = reviews[contentHash];
        require(review.requestedAt == 0, "Review already requested");

        review.contentHash = contentHash;
        review.status = ReviewStatus.PENDING;
        review.requestedAt = block.timestamp;

        emit ReviewRequested(contentHash, msg.sender);

        // Auto-assign available members
        _autoAssignMembers(contentHash);

        return true;
    }

    /**
     * @notice Manually assign members to a review
     * @param contentHash Content to review
     * @param membersToAssign Array of member addresses
     */
    function assignMembers(
        string calldata contentHash,
        address[] calldata membersToAssign
    ) external onlyRole(COUNCIL_ADMIN) {
        NewsReview storage review = reviews[contentHash];
        require(review.requestedAt > 0, "Review not requested");
        require(
            review.status == ReviewStatus.PENDING,
            "Review already in progress"
        );

        for (uint i = 0; i < membersToAssign.length; i++) {
            address member = membersToAssign[i];
            require(members[member].isActive, "Member not active");

            review.assignedMembers.push(member);
            emit MemberAssigned(contentHash, member);
        }

        review.status = ReviewStatus.IN_REVIEW;
    }

    /**
     * @notice Cast vote on a review
     * @param contentHash Content being reviewed
     * @param approve True to approve, false to reject
     * @param reportHash IPFS hash of individual review notes
     */
    function castVote(
        string calldata contentHash,
        bool approve,
        string calldata reportHash
    ) external onlyRole(COUNCIL_MEMBER) {
        NewsReview storage review = reviews[contentHash];
        require(review.status == ReviewStatus.IN_REVIEW, "Not in review");
        require(!review.hasVoted[msg.sender], "Already voted");
        require(
            _isAssigned(contentHash, msg.sender),
            "Not assigned to this review"
        );

        review.hasVoted[msg.sender] = true;
        review.voteDecision[msg.sender] = approve;

        if (approve) {
            review.approvalsCount++;
        } else {
            review.rejectionsCount++;
        }

        emit VoteCast(contentHash, msg.sender, approve);

        // Check if quorum reached
        uint256 totalVotes = review.approvalsCount + review.rejectionsCount;
        if (totalVotes >= quorumSize) {
            _finalizeReview(contentHash, reportHash);
        }
    }

    /**
     * @notice Finalize review after quorum reached
     * @param contentHash Content being reviewed
     * @param reportHash IPFS hash of final report
     */
    function _finalizeReview(
        string memory contentHash,
        string memory reportHash
    ) internal {
        NewsReview storage review = reviews[contentHash];

        uint256 totalVotes = review.approvalsCount + review.rejectionsCount;
        uint256 approvalPercentage = (review.approvalsCount * 10000) /
            totalVotes;

        // Determine final status
        if (approvalPercentage >= approvalThreshold) {
            review.status = ReviewStatus.APPROVED;
        } else if (approvalPercentage <= (10000 - approvalThreshold)) {
            review.status = ReviewStatus.REJECTED;
        } else {
            review.status = ReviewStatus.DISPUTED; // No clear consensus
        }

        review.completedAt = block.timestamp;
        review.finalReport = reportHash;

        // Pay compensation to voting members
        _compensateMembers(contentHash);

        emit ReviewCompleted(contentHash, review.status);
    }

    /**
     * @notice Compensate council members for their review work
     * @param contentHash Content that was reviewed
     */
    function _compensateMembers(string memory contentHash) internal {
        NewsReview storage review = reviews[contentHash];

        for (uint i = 0; i < review.assignedMembers.length; i++) {
            address member = review.assignedMembers[i];

            if (review.hasVoted[member]) {
                // Pay compensation
                (bool success, ) = member.call{value: reviewCompensation}("");
                if (success) {
                    review.compensationPaid += reviewCompensation;
                    members[member].reviewsCompleted++;
                    emit CompensationPaid(member, reviewCompensation);
                }
            }
        }
    }

    /**
     * @notice Auto-assign members to a review based on specialty
     * @param contentHash Content to review
     */
    function _autoAssignMembers(string memory contentHash) internal {
        NewsReview storage review = reviews[contentHash];
        uint256 assigned = 0;

        // Assign up to quorumSize members
        for (
            uint i = 0;
            i < memberAddresses.length && assigned < quorumSize;
            i++
        ) {
            address member = memberAddresses[i];
            if (members[member].isActive) {
                review.assignedMembers.push(member);
                emit MemberAssigned(contentHash, member);
                assigned++;
            }
        }

        if (assigned >= quorumSize) {
            review.status = ReviewStatus.IN_REVIEW;
        }
    }

    /**
     * @notice Check if member is assigned to review
     */
    function _isAssigned(
        string memory contentHash,
        address member
    ) internal view returns (bool) {
        NewsReview storage review = reviews[contentHash];
        for (uint i = 0; i < review.assignedMembers.length; i++) {
            if (review.assignedMembers[i] == member) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Get review details
     */
    function getReview(
        string calldata contentHash
    )
        external
        view
        returns (
            ReviewStatus status,
            uint256 requestedAt,
            uint256 approvalsCount,
            uint256 rejectionsCount,
            address[] memory assignedMembers
        )
    {
        NewsReview storage review = reviews[contentHash];
        return (
            review.status,
            review.requestedAt,
            review.approvalsCount,
            review.rejectionsCount,
            review.assignedMembers
        );
    }

    /**
     * @notice Update review compensation
     */
    function updateCompensation(
        uint256 newCompensation
    ) external onlyRole(COUNCIL_ADMIN) {
        reviewCompensation = newCompensation;
    }

    /**
     * @notice Update quorum size
     */
    function updateQuorum(uint256 newQuorum) external onlyRole(COUNCIL_ADMIN) {
        require(newQuorum > 0, "Invalid quorum");
        quorumSize = newQuorum;
    }

    /**
     * @notice Update approval threshold
     */
    function updateThreshold(
        uint256 newThreshold
    ) external onlyRole(COUNCIL_ADMIN) {
        require(newThreshold <= 10000, "Invalid threshold");
        approvalThreshold = newThreshold;
    }

    // Allow contract to receive ETH for compensation
    receive() external payable {}
}
