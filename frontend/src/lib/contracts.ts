// Contract Configuration
// This file contains all contract addresses and ABIs for the Gono-Moncho DApp

export const CONTRACT_ADDRESSES = {
  NEWS: '0xd3091433da9a925c38682b28ffbae975ed06617a',
  CRED: '0x95e29667e07767bd019b4a79f3979a416c30f573',
  NewsStaking: '0x58321d7cb23248ca3f39f01e4480f4a8b166bfec',
  NewsDAO: '0xccf0212b8c443ee148a36106f109b7b3c5250f51',
  Verification: '0xe5672b7bf38e11d81feb07d77a35cf5499a0adeb',
  ArweaveStorage: '0xc7311a7c71647edd9556938ad6f22afe4dc01a66',
  DelegationRegistry: '0xea67b90c7d566ae98c4906fa8962844fb424e4f0',
  ReporterRegistry: '0x0000000000000000000000000000000000000000', // TODO: Update after deployment
  // Note: AIOracle address not provided - AI analysis will be accessed through Verification contract
  AIOracle: '0x0000000000000000000000000000000000000000' // Placeholder - update when deployed
} as const;

// Simplified ABI for NewsDAO (main contract for frontend interaction)
export const NewsDAOABI = [
  {
    "type": "function",
    "name": "createProposal",
    "stateMutability": "nonpayable",
    "inputs": [{ "name": "pType", "type": "uint8" }],
    "outputs": [{ "name": "", "type": "uint256" }]
  },
  {
    "type": "function",
    "name": "vote",
    "stateMutability": "nonpayable",
    "inputs": [
      { "name": "proposalId", "type": "uint256" },
      { "name": "support", "type": "bool" },
      { "name": "votes", "type": "uint256" }
    ],
    "outputs": []
  },
  {
    "type": "function",
    "name": "proposals",
    "stateMutability": "view",
    "inputs": [{ "name": "", "type": "uint256" }],
    "outputs": [
      { "name": "id", "type": "uint256" },
      { "name": "pType", "type": "uint8" },
      { "name": "proposer", "type": "address" },
      { "name": "forVotes", "type": "uint256" },
      { "name": "againstVotes", "type": "uint256" },
      { "name": "createdAt", "type": "uint256" },
      { "name": "executed", "type": "bool" }
    ]
  }
] as const;

// Verification Contract ABI
export const VerificationABI = [
  {
    "type": "function",
    "name": "publishNews",
    "stateMutability": "nonpayable",
    "inputs": [{ "name": "contentHash", "type": "string" }],
    "outputs": []
  },
  {
    "type": "function",
    "name": "addVerifierScore",
    "stateMutability": "nonpayable",
    "inputs": [
      { "name": "contentHash", "type": "string" },
      { "name": "score", "type": "uint256" }
    ],
    "outputs": []
  },
  {
    "type": "function",
    "name": "requestAIVerification",
    "stateMutability": "nonpayable",
    "inputs": [{ "name": "contentHash", "type": "string" }],
    "outputs": []
  },
  {
    "type": "function",
    "name": "finalizeVerification",
    "stateMutability": "nonpayable",
    "inputs": [{ "name": "contentHash", "type": "string" }],
    "outputs": []
  },
  {
    "type": "function",
    "name": "newsItems",
    "stateMutability": "view",
    "inputs": [{ "name": "", "type": "string" }],
    "outputs": [
      { "name": "reporter", "type": "address" },
      { "name": "arweaveHash", "type": "string" },
      { "name": "analyzerScores", "type": "uint256[]" },
      { "name": "verifierScores", "type": "uint256[]" },
      { "name": "status", "type": "uint8" },
      { "name": "credibilityScore", "type": "uint256" }
    ]
  },
  {
    "type": "event",
    "name": "NewsPublished",
    "inputs": [
      { "name": "arweaveHash", "type": "string", "indexed": true },
      { "name": "reporter", "type": "address", "indexed": true }
    ]
  },
  {
    "type": "event",
    "name": "NewsVerified",
    "inputs": [
      { "name": "arweaveHash", "type": "string", "indexed": true },
      { "name": "status", "type": "uint8", "indexed": false }
    ]
  }
] as const;

// NEWS Token ABI
export const NEWSABI = [
  {
    "type": "function",
    "name": "balanceOf",
    "stateMutability": "view",
    "inputs": [{ "name": "account", "type": "address" }],
    "outputs": [{ "name": "", "type": "uint256" }]
  },
  {
    "type": "function",
    "name": "transfer",
    "stateMutability": "nonpayable",
    "inputs": [
      { "name": "to", "type": "address" },
      { "name": "amount", "type": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "bool" }]
  },
  {
    "type": "function",
    "name": "approve",
    "stateMutability": "nonpayable",
    "inputs": [
      { "name": "spender", "type": "address" },
      { "name": "amount", "type": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "bool" }]
  }
] as const;

// CRED Token ABI
export const CREDABI = [
  {
    "type": "function",
    "name": "balanceOf",
    "stateMutability": "view",
    "inputs": [{ "name": "account", "type": "address" }],
    "outputs": [{ "name": "", "type": "uint256" }]
  },
  {
    "type": "function",
    "name": "totalSupply",
    "stateMutability": "view",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256" }]
  }
] as const;

// NewsStaking ABI
export const NewsStakingABI = [
  {
    "type": "function",
    "name": "stake",
    "stateMutability": "nonpayable",
    "inputs": [{ "name": "amount", "type": "uint256" }],
    "outputs": []
  },
  {
    "type": "function",
    "name": "unstake",
    "stateMutability": "nonpayable",
    "inputs": [{ "name": "amount", "type": "uint256" }],
    "outputs": []
  },
  {
    "type": "function",
    "name": "getStakedAmount",
    "stateMutability": "view",
    "inputs": [{ "name": "user", "type": "address" }],
    "outputs": [
      { "name": "", "type": "uint256" },
      { "name": "", "type": "uint256" }
    ]
  },
  {
    "type": "function",
    "name": "getAllStakers",
    "stateMutability": "view",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address[]" }]
  },
  {
    "type": "function",
    "name": "stakes",
    "stateMutability": "view",
    "inputs": [{ "name": "", "type": "address" }],
    "outputs": [
      { "name": "amount", "type": "uint256" },
      { "name": "stakedAt", "type": "uint256" }
    ]
  }
] as const;

// ArweaveStorage ABI
export const ArweaveStorageABI = [
  {
    "type": "function",
    "name": "storeReference",
    "stateMutability": "nonpayable",
    "inputs": [
      { "name": "contentHash", "type": "string" },
      { "name": "owner", "type": "address" }
    ],
    "outputs": []
  },
  {
    "type": "function",
    "name": "contentOwner",
    "stateMutability": "view",
    "inputs": [{ "name": "", "type": "string" }],
    "outputs": [{ "name": "", "type": "address" }]
  },
  {
    "type": "event",
    "name": "ContentStored",
    "inputs": [
      { "name": "contentHash", "type": "string", "indexed": true },
      { "name": "owner", "type": "address", "indexed": true }
    ]
  }
] as const;

// AIOracle ABI
export const AIOracleABI = [
  {
    "type": "function",
    "name": "requestAnalysis",
    "stateMutability": "nonpayable",
    "inputs": [{ "name": "contentHash", "type": "string" }],
    "outputs": []
  },
  {
    "type": "function",
    "name": "getAnalysis",
    "stateMutability": "view",
    "inputs": [{ "name": "contentHash", "type": "string" }],
    "outputs": [{ "name": "credibilityScore", "type": "uint256" }]
  }
] as const;

// DelegationRegistry ABI
export const DelegationRegistryABI = [
  {
    "type": "function",
    "name": "setDelegate",
    "stateMutability": "nonpayable",
    "inputs": [
      { "name": "topic", "type": "uint256" },
      { "name": "delegate", "type": "address" }
    ],
    "outputs": []
  },
  {
    "type": "function",
    "name": "getDelegate",
    "stateMutability": "view",
    "inputs": [
      { "name": "delegator", "type": "address" },
      { "name": "topic", "type": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "address" }]
  },
  {
    "type": "event",
    "name": "DelegateSet",
    "inputs": [
      { "name": "delegator", "type": "address", "indexed": true },
      { "name": "topic", "type": "uint256", "indexed": true },
      { "name": "delegate", "type": "address", "indexed": true }
    ]
  }
] as const;

// ReporterRegistry ABI
export const ReporterRegistryABI = [
  {
    "type": "function",
    "name": "registerReporter",
    "stateMutability": "nonpayable",
    "inputs": [
      { "name": "_ipfsMetadata", "type": "string" },
      { "name": "_role", "type": "uint8" }
    ],
    "outputs": []
  },
  {
    "type": "function",
    "name": "stakeTokens",
    "stateMutability": "nonpayable",
    "inputs": [{ "name": "_amount", "type": "uint256" }],
    "outputs": []
  },
  {
    "type": "function",
    "name": "verifyReporter",
    "stateMutability": "nonpayable",
    "inputs": [
      { "name": "_reporter", "type": "address" },
      { "name": "_approve", "type": "bool" }
    ],
    "outputs": []
  },
  {
    "type": "function",
    "name": "withdrawStake",
    "stateMutability": "nonpayable",
    "inputs": [{ "name": "_amount", "type": "uint256" }],
    "outputs": []
  },
  {
    "type": "function",
    "name": "canPublish",
    "stateMutability": "view",
    "inputs": [{ "name": "_user", "type": "address" }],
    "outputs": [{ "name": "", "type": "bool" }]
  },
  {
    "type": "function",
    "name": "canVerify",
    "stateMutability": "view",
    "inputs": [{ "name": "_user", "type": "address" }],
    "outputs": [{ "name": "", "type": "bool" }]
  },
  {
    "type": "function",
    "name": "getReporterProfile",
    "stateMutability": "view",
    "inputs": [{ "name": "_reporter", "type": "address" }],
    "outputs": [
      { "name": "role", "type": "uint8" },
      { "name": "status", "type": "uint8" },
      { "name": "stakedAmount", "type": "uint256" },
      { "name": "registeredAt", "type": "uint256" },
      { "name": "verifiedAt", "type": "uint256" },
      { "name": "ipfsMetadata", "type": "string" },
      { "name": "verifiedBy", "type": "address" },
      { "name": "publishedArticles", "type": "uint256" },
      { "name": "isFreeTestAccount", "type": "bool" }
    ]
  },
  {
    "type": "function",
    "name": "reporters",
    "stateMutability": "view",
    "inputs": [{ "name": "", "type": "address" }],
    "outputs": [
      { "name": "role", "type": "uint8" },
      { "name": "status", "type": "uint8" },
      { "name": "stakedAmount", "type": "uint256" },
      { "name": "registeredAt", "type": "uint256" },
      { "name": "verifiedAt", "type": "uint256" },
      { "name": "ipfsMetadata", "type": "string" },
      { "name": "verifiedBy", "type": "address" },
      { "name": "publishedArticles", "type": "uint256" },
      { "name": "isFreeTestAccount", "type": "bool" }
    ]
  },
  {
    "type": "function",
    "name": "testingMode",
    "stateMutability": "view",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bool" }]
  },
  {
    "type": "event",
    "name": "ReporterRegistered",
    "inputs": [
      { "name": "reporter", "type": "address", "indexed": true },
      { "name": "role", "type": "uint8", "indexed": false },
      { "name": "ipfsMetadata", "type": "string", "indexed": false }
    ]
  },
  {
    "type": "event",
    "name": "ReporterVerified",
    "inputs": [
      { "name": "reporter", "type": "address", "indexed": true },
      { "name": "verifier", "type": "address", "indexed": true },
      { "name": "approved", "type": "bool", "indexed": false }
    ]
  },
  {
    "type": "event",
    "name": "StakeDeposited",
    "inputs": [
      { "name": "reporter", "type": "address", "indexed": true },
      { "name": "amount", "type": "uint256", "indexed": false }
    ]
  }
] as const;

// Export a helper function to check if contracts are deployed\n
export function areContractsDeployed(): boolean {
  return true; // Contracts are deployed on Polygon Amoy
}

// Helper to load contract addresses from deployments.json
export async function loadContractAddresses() {
  try {
    const response = await fetch('/deployments.json');
    const deployments = await response.json();
    return deployments;
  } catch (error) {
    console.warn('Could not load deployments.json:', error);
    return CONTRACT_ADDRESSES;
  }
}
