// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title SANUB - Sharing and Analyzing News Using Blockchain
 * @notice Implements the complete SANUB credibility calculation model from the whitepaper
 * @dev Mathematical model for calculating news credibility, reporter credit, and analyst credit
 *
 * Based on formulas from the Gono Moncho whitepaper:
 * - Belief calculation (Equation 1)
 * - Importance calculation (Equation 2)
 * - Sigmoid normalization (Equation 3)
 * - Analyst credit (Equations 4-5)
 * - Reporter credit (Equation 6)
 * - News credibility (Equation 7)
 */
library SANUB {
    // Fixed-point precision for calculations (18 decimals)
    uint256 constant PRECISION = 1e18;

    /**
     * @notice Calculate public belief in a news item (Equation 1)
     * @param scores Array of verifier scores (0 or 1)
     * @return belief Average score from all verifiers (Bn)
     *
     * Formula: Bn = Σ(pk) / Nn
     * where pk is the score from the k-th verifier, Nn is total verifiers
     */
    function calculateBelief(
        uint256[] memory scores
    ) internal pure returns (uint256 belief) {
        require(scores.length > 0, "No scores provided");

        uint256 sum = 0;
        for (uint i = 0; i < scores.length; i++) {
            require(scores[i] <= 100, "Score must be 0-100");
            sum += scores[i];
        }

        // Return as fixed-point number (0-100 scaled to 1e18)
        belief = (sum * PRECISION) / (scores.length * 100);
        return belief;
    }

    /**
     * @notice Calculate importance of a news item (Equation 2)
     * @param verifiersCount Number of users who verified this news
     * @param totalUsers Total number of users in the system
     * @return importance Importance score (In)
     *
     * Formula: In = Nn / NT
     * where Nn is verifiers count, NT is total users
     */
    function calculateImportance(
        uint256 verifiersCount,
        uint256 totalUsers
    ) internal pure returns (uint256 importance) {
        require(totalUsers > 0, "Total users must be > 0");
        require(verifiersCount <= totalUsers, "Invalid verifier count");

        // Return as fixed-point number
        importance = (verifiersCount * PRECISION) / totalUsers;
        return importance;
    }

    /**
     * @notice Sigmoid function to normalize belief score (Equation 3)
     * @param belief Public belief score (0-1 scaled to 1e18)
     * @return normalized Normalized score using sigmoid function
     *
     * Formula: S(Bn) = 1 / (1 + e^(-(Bn - 0.75)))
     */
    function sigmoidFunction(
        uint256 belief
    ) internal pure returns (uint256 normalized) {
        // Belief is in range [0, 1e18]
        // Shift by 0.75 (0.75e18)
        int256 shifted = int256(belief) - int256((75 * PRECISION) / 100);

        // Calculate e^(-shifted) using approximation
        int256 expValue = exponential(-shifted);

        // S(Bn) = 1 / (1 + expValue)
        normalized = (PRECISION * PRECISION) / (PRECISION + uint256(expValue));

        return normalized;
    }

    /**
     * @notice Calculate analyst's credit score (Equations 4-5)
     * @param correctConfirmed Number of news items correctly confirmed
     * @param correctRejected Number of news items correctly rejected
     * @param totalAnalyzed Total number of news items analyzed
     * @param confirmedBeliefs Array of belief scores for confirmed items
     * @param rejectedBeliefs Array of belief scores for rejected items
     * @return credit Analyst's credit score (Ca)
     *
     * Formula: Tp = Σ S(Bni) + Σ S(1-Bnj)
     *          Ca = (Tp / (Tp + (at - Tp)^2 + 1)) * (1/at)
     */
    function calculateAnalystCredit(
        uint256 correctConfirmed,
        uint256 correctRejected,
        uint256 totalAnalyzed,
        uint256[] memory confirmedBeliefs,
        uint256[] memory rejectedBeliefs
    ) internal pure returns (uint256 credit) {
        require(totalAnalyzed > 0, "Must have analyzed items");
        require(
            confirmedBeliefs.length == correctConfirmed,
            "Beliefs count mismatch"
        );
        require(
            rejectedBeliefs.length == correctRejected,
            "Rejected beliefs count mismatch"
        );

        // Calculate Tp (total positive credit)
        uint256 Tp = 0;

        // Add sigmoid scores for correctly confirmed news
        for (uint i = 0; i < confirmedBeliefs.length; i++) {
            Tp += sigmoidFunction(confirmedBeliefs[i]);
        }

        // Add sigmoid scores for correctly rejected news (1 - Bn)
        for (uint j = 0; j < rejectedBeliefs.length; j++) {
            uint256 invertedBelief = PRECISION - rejectedBeliefs[j];
            Tp += sigmoidFunction(invertedBelief);
        }

        // Calculate (at - Tp)^2
        uint256 incorrect = totalAnalyzed -
            (correctConfirmed + correctRejected);
        uint256 incorrectSquared = (incorrect * incorrect * PRECISION) /
            PRECISION;

        // Ca = (Tp / (Tp + (at-Tp)^2 + 1)) * (1/at)
        uint256 denominator = Tp + incorrectSquared + PRECISION;
        credit = (Tp * PRECISION * PRECISION) / (denominator * totalAnalyzed);

        return credit;
    }

    /**
     * @notice Calculate reporter's credit score (Equation 6)
     * @param newsItems Array of news item data
     * @return credit Reporter's credit score (Cr)
     *
     * Formula: Cr = Σ ((Σ Caj / (Σ Caj + Σ Cak)^2 + 1) * (1/ati) * Ini)
     */
    function calculateReporterCredit(
        NewsItemData[] memory newsItems
    ) internal pure returns (uint256 credit) {
        require(newsItems.length > 0, "No news items");

        uint256 totalCredit = 0;

        for (uint i = 0; i < newsItems.length; i++) {
            NewsItemData memory item = newsItems[i];

            // Sum of supporting analyst credits
            uint256 supportSum = sumArray(item.supportingAnalystCredits);

            // Sum of rejecting analyst credits
            uint256 rejectSum = sumArray(item.rejectingAnalystCredits);

            // Total analysts for this item
            uint256 totalAnalysts = item.supportingAnalystCredits.length +
                item.rejectingAnalystCredits.length;

            if (totalAnalysts == 0) continue;

            // Calculate fraction: supportSum / (supportSum + rejectSum)^2 + 1
            uint256 denominator = ((supportSum + rejectSum) *
                (supportSum + rejectSum)) /
                PRECISION +
                PRECISION;
            uint256 fraction = (supportSum * PRECISION) / denominator;

            // Multiply by (1/ati) and importance
            uint256 itemCredit = (fraction * item.importance) /
                (totalAnalysts * PRECISION);

            totalCredit += itemCredit;
        }

        return totalCredit;
    }

    /**
     * @notice Calculate final news credibility (Equation 7)
     * @param reporterCredit Credit score of the reporter (Cr)
     * @param supportingAnalystCredits Array of credits from analysts who supported
     * @param rejectingAnalystCredits Array of credits from analysts who rejected
     * @return credibility Final news credibility score (Cn)
     *
     * Formula: Cn = (Σ Cai * Cr) / (Σ Cai + Σ Cak)
     */
    function calculateNewsCredibility(
        uint256 reporterCredit,
        uint256[] memory supportingAnalystCredits,
        uint256[] memory rejectingAnalystCredits
    ) internal pure returns (uint256 credibility) {
        uint256 supportSum = sumArray(supportingAnalystCredits);
        uint256 rejectSum = sumArray(rejectingAnalystCredits);

        uint256 totalAnalystCredit = supportSum + rejectSum;
        require(totalAnalystCredit > 0, "No analyst input");

        // Cn = (supportSum * Cr) / totalAnalystCredit
        credibility = (supportSum * reporterCredit) / totalAnalystCredit;

        return credibility;
    }

    /**
     * @notice Helper: Calculate exponential using Taylor series approximation
     * @param x Input value (can be negative)
     * @return result e^x approximation
     */
    function exponential(int256 x) private pure returns (int256 result) {
        // Taylor series: e^x ≈ 1 + x + x^2/2! + x^3/3! + x^4/4! + ...
        // Using first 10 terms for accuracy

        int256 term = int256(PRECISION); // First term = 1
        result = term;

        for (uint i = 1; i <= 10; i++) {
            term = (term * x) / (int256(i) * int256(PRECISION));
            result += term;

            // Break early if term becomes negligible
            if (abs(term) < 1e10) break;
        }

        return result > 0 ? result : int256(PRECISION / 1000); // Minimum value to avoid division by zero
    }

    /**
     * @notice Helper: Sum an array of uint256 values
     */
    function sumArray(uint256[] memory arr) private pure returns (uint256 sum) {
        for (uint i = 0; i < arr.length; i++) {
            sum += arr[i];
        }
        return sum;
    }

    /**
     * @notice Helper: Absolute value of int256
     */
    function abs(int256 x) private pure returns (int256) {
        return x >= 0 ? x : -x;
    }
}

/**
 * @notice Struct for reporter credit calculation
 */
struct NewsItemData {
    uint256[] supportingAnalystCredits;
    uint256[] rejectingAnalystCredits;
    uint256 importance;
}
