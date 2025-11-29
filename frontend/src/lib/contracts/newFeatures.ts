// Frontend Integration Package for Gono Moncho Platform
// ABIs and Type Definitions for New Features

export const TokenEconomicsABI = [
  {
    "inputs": [
      {"internalType": "address", "name": "_newsToken", "type": "address"},
      {"internalType": "address", "name": "_treasury", "type": "address"},
      {"internalType": "address", "name": "_owner", "type": "address"}
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true, "internalType": "address", "name": "payer", "type": "address"},
      {"indexed": false, "internalType": "uint256", "name": "amount", "type": "uint256"},
      {"indexed": false, "internalType": "string", "name": "revenueType", "type": "string"}
    ],
    "name": "RevenueCollected",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": false, "internalType": "uint256", "name": "ethSpent", "type": "uint256"},
      {"indexed": false, "internalType": "uint256", "name": "tokensBurned", "type": "uint256"}
    ],
    "name": "BuybackExecuted",
    "type": "event"
  },
  {
    "inputs": [{"internalType": "uint256", "name": "amount", "type": "uint256"}],
    "name": "collectSyndicationRevenue",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "uint256", "name": "amount", "type": "uint256"}],
    "name": "collectAnalyticsRevenue",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getStats",
    "outputs": [
      {"internalType": "uint256", "name": "revenue", "type": "uint256"},
      {"internalType": "uint256", "name": "burned", "type": "uint256"},
      {"internalType": "uint256", "name": "treasury", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
] as const;

export const ProofOfHumanityABI = [
  {
    "inputs": [{"internalType": "address", "name": "_owner", "type": "address"}],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true, "internalType": "address", "name": "user", "type": "address"},
      {"indexed": false, "internalType": "uint8", "name": "confidenceScore", "type": "uint8"}
    ],
    "name": "ProofSubmitted",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true, "internalType": "address", "name": "user", "type": "address"},
      {"indexed": false, "internalType": "bool", "name": "verified", "type": "bool"}
    ],
    "name": "HumanVerified",
    "type": "event"
  },
  {
    "inputs": [
      {"internalType": "bytes32", "name": "contextHash", "type": "bytes32"},
      {"internalType": "uint8", "name": "confidenceScore", "type": "uint8"},
      {"internalType": "address[]", "name": "connections", "type": "address[]"}
    ],
    "name": "submitProof",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "address", "name": "user", "type": "address"}],
    "name": "isVerified",
    "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "address", "name": "user", "type": "address"}],
    "name": "getSocialMetrics",
    "outputs": [
      {"internalType": "uint256", "name": "connectionCount", "type": "uint256"},
      {"internalType": "uint8", "name": "confidenceScore", "type": "uint8"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
] as const;

export const ZeroKnowledgePublishingABI = [
  {
    "inputs": [
      {"internalType": "address", "name": "_reporterRegistry", "type": "address"},
      {"internalType": "address", "name": "_owner", "type": "address"}
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true, "internalType": "uint256", "name": "commitId", "type": "uint256"},
      {"indexed": false, "internalType": "bytes32", "name": "commitment", "type": "bytes32"}
    ],
    "name": "AnonymousPublishCommitted",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true, "internalType": "uint256", "name": "commitId", "type": "uint256"},
      {"indexed": false, "internalType": "bytes32", "name": "contentHash", "type": "bytes32"}
    ],
    "name": "ContentRevealed",
    "type": "event"
  },
  {
    "inputs": [
      {"internalType": "bytes32", "name": "commitment", "type": "bytes32"},
      {"internalType": "string", "name": "category", "type": "string"}
    ],
    "name": "commitAnonymousPublish",
    "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "uint256", "name": "commitId", "type": "uint256"},
      {"internalType": "bytes32", "name": "contentHash", "type": "bytes32"},
      {"internalType": "address", "name": "author", "type": "address"}
    ],
    "name": "revealContent",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "uint256", "name": "commitId", "type": "uint256"}],
    "name": "getCommitment",
    "outputs": [
      {"internalType": "bytes32", "name": "commitment", "type": "bytes32"},
      {"internalType": "bytes32", "name": "revealedContent", "type": "bytes32"},
      {"internalType": "uint256", "name": "timestamp", "type": "uint256"},
      {"internalType": "string", "name": "category", "type": "string"},
      {"internalType": "uint8", "name": "status", "type": "uint8"},
      {"internalType": "address", "name": "author", "type": "address"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
] as const;

export const CREDRewardDistributorABI = [
  {
    "inputs": [
      {"internalType": "address", "name": "_credToken", "type": "address"},
      {"internalType": "address", "name": "_newsToken", "type": "address"},
      {"internalType": "address", "name": "_staking", "type": "address"},
      {"internalType": "address", "name": "_registry", "type": "address"},
      {"internalType": "address", "name": "_owner", "type": "address"}
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true, "internalType": "address", "name": "recipient", "type": "address"},
      {"indexed": false, "internalType": "uint256", "name": "amount", "type": "uint256"},
      {"indexed": false, "internalType": "string", "name": "rewardType", "type": "string"}
    ],
    "name": "RewardDistributed",
    "type": "event"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "reporter", "type": "address"},
      {"internalType": "uint8", "name": "qualityScore", "type": "uint8"}
    ],
    "name": "rewardPublishing",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "verifier", "type": "address"},
      {"internalType": "bool", "name": "accurate", "type": "bool"}
    ],
    "name": "rewardVerification",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "claimStakingRewards",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "address", "name": "participant", "type": "address"}],
    "name": "rewardGovernanceParticipation",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "address", "name": "user", "type": "address"}],
    "name": "getUserRewardStats",
    "outputs": [
      {"internalType": "uint256", "name": "totalEarned", "type": "uint256"},
      {"internalType": "uint256", "name": "publishCount", "type": "uint256"},
      {"internalType": "uint256", "name": "verifyCount", "type": "uint256"},
      {"internalType": "uint256", "name": "govCount", "type": "uint256"},
      {"internalType": "uint256", "name": "currentBalance", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
] as const;

export const JournalisticIntegrityCouncilABI = [
  {
    "inputs": [
      {"internalType": "address", "name": "_credToken", "type": "address"},
      {"internalType": "address", "name": "_owner", "type": "address"}
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true, "internalType": "uint256", "name": "reviewId", "type": "uint256"},
      {"indexed": false, "internalType": "bytes32", "name": "contentHash", "type": "bytes32"}
    ],
    "name": "ReviewRequested",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true, "internalType": "uint256", "name": "reviewId", "type": "uint256"},
      {"indexed": true, "internalType": "address", "name": "member", "type": "address"},
      {"indexed": false, "internalType": "bool", "name": "approved", "type": "bool"}
    ],
    "name": "VoteCast",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true, "internalType": "uint256", "name": "reviewId", "type": "uint256"},
      {"indexed": false, "internalType": "bool", "name": "approved", "type": "bool"}
    ],
    "name": "ReviewFinalized",
    "type": "event"
  },
  {
    "inputs": [
      {"internalType": "bytes32", "name": "contentHash", "type": "bytes32"},
      {"internalType": "string", "name": "specialty", "type": "string"},
      {"internalType": "string", "name": "reason", "type": "string"}
    ],
    "name": "requestReview",
    "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "uint256", "name": "reviewId", "type": "uint256"},
      {"internalType": "bool", "name": "approve", "type": "bool"},
      {"internalType": "string", "name": "feedback", "type": "string"}
    ],
    "name": "castVote",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "uint256", "name": "reviewId", "type": "uint256"}],
    "name": "getReview",
    "outputs": [
      {"internalType": "bytes32", "name": "contentHash", "type": "bytes32"},
      {"internalType": "address", "name": "requester", "type": "address"},
      {"internalType": "string", "name": "specialty", "type": "string"},
      {"internalType": "uint8", "name": "votesFor", "type": "uint8"},
      {"internalType": "uint8", "name": "votesAgainst", "type": "uint8"},
      {"internalType": "uint256", "name": "timestamp", "type": "uint256"},
      {"internalType": "bool", "name": "finalized", "type": "bool"},
      {"internalType": "bool", "name": "approved", "type": "bool"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
] as const;

export const ReputationWeightedVotingABI = [
  {
    "inputs": [
      {"internalType": "address", "name": "voter", "type": "address"},
      {"internalType": "address", "name": "stakingContract", "type": "address"},
      {"internalType": "address", "name": "credToken", "type": "address"},
      {"internalType": "uint256", "name": "stakeWeight", "type": "uint256"},
      {"internalType": "uint256", "name": "reputationWeight", "type": "uint256"}
    ],
    "name": "calculateVotingPower",
    "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "voter", "type": "address"},
      {"internalType": "address", "name": "stakingContract", "type": "address"},
      {"internalType": "address", "name": "credToken", "type": "address"},
      {"internalType": "uint256", "name": "stakeWeight", "type": "uint256"},
      {"internalType": "uint256", "name": "reputationWeight", "type": "uint256"}
    ],
    "name": "getVotingPowerBreakdown",
    "outputs": [
      {"internalType": "uint256", "name": "totalPower", "type": "uint256"},
      {"internalType": "uint256", "name": "fromStake", "type": "uint256"},
      {"internalType": "uint256", "name": "fromReputation", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
] as const;

// TypeScript Types
export interface TokenEconomicsStats {
  revenue: bigint;
  burned: bigint;
  treasury: bigint;
}

export interface SocialMetrics {
  connectionCount: bigint;
  confidenceScore: number;
}

export interface ZKCommitment {
  commitment: string;
  revealedContent: string;
  timestamp: bigint;
  category: string;
  status: PublishStatus;
  author: string;
}

export enum PublishStatus {
  COMMITTED = 0,
  REVEALED = 1,
  VERIFIED = 2,
  REJECTED = 3
}

export interface UserRewardStats {
  totalEarned: bigint;
  publishCount: bigint;
  verifyCount: bigint;
  govCount: bigint;
  currentBalance: bigint;
}

export interface CouncilReview {
  contentHash: string;
  requester: string;
  specialty: string;
  votesFor: number;
  votesAgainst: number;
  timestamp: bigint;
  finalized: boolean;
  approved: boolean;
}

export interface VotingPowerBreakdown {
  totalPower: bigint;
  fromStake: bigint;
  fromReputation: bigint;
}

// Contract Addresses (Update after deployment)
export const CONTRACT_ADDRESSES = {
  TokenEconomics: "0x0000000000000000000000000000000000000000",
  ProofOfHumanity: "0x0000000000000000000000000000000000000000",
  ZeroKnowledgePublishing: "0x0000000000000000000000000000000000000000",
  CREDRewardDistributor: "0x0000000000000000000000000000000000000000",
  JournalisticIntegrityCouncil: "0x0000000000000000000000000000000000000000",
  ReputationWeightedVoting: "0x0000000000000000000000000000000000000000",
} as const;

// Helper Functions
export const formatCRED = (amount: bigint): string => {
  return (Number(amount) / 1e18).toFixed(2);
};

export const parseCRED = (amount: string): bigint => {
  return BigInt(Math.floor(parseFloat(amount) * 1e18));
};

export const getPublishStatusLabel = (status: PublishStatus): string => {
  const labels = {
    [PublishStatus.COMMITTED]: "Committed",
    [PublishStatus.REVEALED]: "Revealed",
    [PublishStatus.VERIFIED]: "Verified",
    [PublishStatus.REJECTED]: "Rejected",
  };
  return labels[status];
};
