// Organization Features Contract ABIs and Addresses

export const NEWS_OUTLET_REGISTRY_ADDRESS = '0x...' as const; // TODO: Update after deployment

export const NEWS_OUTLET_REGISTRY_ABI = [
  {
    "inputs": [
      {"internalType": "address", "name": "_owner", "type": "address"}
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "inputs": [
      {"internalType": "string", "name": "_name", "type": "string"},
      {"internalType": "string", "name": "_legalEntity", "type": "string"},
      {"internalType": "string", "name": "_registrationNumber", "type": "string"},
      {"internalType": "string", "name": "_jurisdiction", "type": "string"},
      {"internalType": "string", "name": "_website", "type": "string"},
      {"internalType": "address", "name": "_treasuryAddress", "type": "address"}
    ],
    "name": "registerOutlet",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "_journalist", "type": "address"},
      {"internalType": "string", "name": "_role", "type": "string"}
    ],
    "name": "affiliateJournalist",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "_journalist", "type": "address"}
    ],
    "name": "removeJournalist",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "generateAPIKey",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "", "type": "address"}
    ],
    "name": "outlets",
    "outputs": [
      {"internalType": "string", "name": "name", "type": "string"},
      {"internalType": "string", "name": "legalEntity", "type": "string"},
      {"internalType": "string", "name": "registrationNumber", "type": "string"},
      {"internalType": "string", "name": "jurisdiction", "type": "string"},
      {"internalType": "string", "name": "website", "type": "string"},
      {"internalType": "address", "name": "treasuryAddress", "type": "address"},
      {"internalType": "uint256", "name": "stakeAmount", "type": "uint256"},
      {"internalType": "uint8", "name": "status", "type": "uint8"},
      {"internalType": "uint8", "name": "tier", "type": "uint8"},
      {"internalType": "uint256", "name": "credibilityScore", "type": "uint256"},
      {"internalType": "uint256", "name": "registeredAt", "type": "uint256"},
      {"internalType": "uint256", "name": "verifiedAt", "type": "uint256"},
      {"internalType": "string", "name": "apiKey", "type": "string"},
      {"internalType": "bool", "name": "apiEnabled", "type": "bool"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "_outlet", "type": "address"},
      {"internalType": "address", "name": "_journalist", "type": "address"}
    ],
    "name": "isAffiliatedJournalist",
    "outputs": [
      {"internalType": "bool", "name": "", "type": "bool"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
] as const;

export const ORGANIZATION_STAKING_ADDRESS = '0x...' as const; // TODO: Update after deployment

export const ORGANIZATION_STAKING_ABI = [
  {
    "inputs": [
      {"internalType": "address", "name": "_newsToken", "type": "address"}
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "inputs": [
      {"internalType": "uint256", "name": "_amount", "type": "uint256"}
    ],
    "name": "depositOrganizationStake",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "_journalist", "type": "address"},
      {"internalType": "uint256", "name": "_amount", "type": "uint256"}
    ],
    "name": "allocateToJournalist",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "_journalist", "type": "address"},
      {"internalType": "uint256", "name": "_amount", "type": "uint256"}
    ],
    "name": "deallocateFromJournalist",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "_organization", "type": "address"}
    ],
    "name": "distributeRewards",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "_organization", "type": "address"}
    ],
    "name": "claimJournalistRewards",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "", "type": "address"}
    ],
    "name": "organizationTotalStake",
    "outputs": [
      {"internalType": "uint256", "name": "", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "_journalist", "type": "address"}
    ],
    "name": "getTotalJournalistBacking",
    "outputs": [
      {"internalType": "uint256", "name": "", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
] as const;

export const DECENTRALIZED_PUBLISHING_API_ADDRESS = '0x...' as const; // TODO: Update after deployment

export const DECENTRALIZED_PUBLISHING_API_ABI = [
  {
    "inputs": [
      {"internalType": "address", "name": "_owner", "type": "address"}
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "_outlet", "type": "address"}
    ],
    "name": "generateAPIKey",
    "outputs": [
      {"internalType": "string", "name": "", "type": "string"}
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "string", "name": "_apiKey", "type": "string"},
      {"internalType": "address", "name": "_author", "type": "address"},
      {"internalType": "string", "name": "_title", "type": "string"},
      {"internalType": "string", "name": "_contentHash", "type": "string"},
      {"internalType": "string", "name": "_category", "type": "string"}
    ],
    "name": "submitArticle",
    "outputs": [
      {"internalType": "uint256", "name": "", "type": "uint256"}
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "string", "name": "_apiKey", "type": "string"},
      {"internalType": "address[]", "name": "_authors", "type": "address[]"},
      {"internalType": "string[]", "name": "_titles", "type": "string[]"},
      {"internalType": "string[]", "name": "_contentHashes", "type": "string[]"},
      {"internalType": "string[]", "name": "_categories", "type": "string[]"}
    ],
    "name": "batchSubmitArticles",
    "outputs": [
      {"internalType": "uint256[]", "name": "", "type": "uint256[]"}
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "", "type": "address"}
    ],
    "name": "outletAPIKeys",
    "outputs": [
      {"internalType": "string", "name": "apiKey", "type": "string"},
      {"internalType": "bool", "name": "isActive", "type": "bool"},
      {"internalType": "uint256", "name": "createdAt", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "_outlet", "type": "address"}
    ],
    "name": "getRateLimitStatus",
    "outputs": [
      {"internalType": "uint256", "name": "used", "type": "uint256"},
      {"internalType": "uint256", "name": "limit", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "uint256", "name": "", "type": "uint256"}
    ],
    "name": "publishRequests",
    "outputs": [
      {"internalType": "address", "name": "outlet", "type": "address"},
      {"internalType": "address", "name": "author", "type": "address"},
      {"internalType": "string", "name": "title", "type": "string"},
      {"internalType": "string", "name": "contentHash", "type": "string"},
      {"internalType": "string", "name": "category", "type": "string"},
      {"internalType": "bool", "name": "processed", "type": "bool"},
      {"internalType": "bool", "name": "approved", "type": "bool"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
] as const;

export const SYNDICATION_LICENSING_ADDRESS = '0x...' as const; // TODO: Update after deployment

export const SYNDICATION_LICENSING_ABI = [
  {
    "inputs": [
      {"internalType": "address", "name": "_owner", "type": "address"}
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "inputs": [
      {"internalType": "string", "name": "_name", "type": "string"},
      {"internalType": "uint256", "name": "_subscriberCount", "type": "uint256"}
    ],
    "name": "registerLicensee",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "string", "name": "_contentId", "type": "string"},
      {"internalType": "bool", "name": "_exclusive", "type": "bool"}
    ],
    "name": "purchaseLicense",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "string", "name": "_contentId", "type": "string"},
      {"internalType": "string", "name": "_republishUrl", "type": "string"}
    ],
    "name": "recordRepublish",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "withdrawJournalistRevenue",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "withdrawOutletRevenue",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "", "type": "address"}
    ],
    "name": "licensees",
    "outputs": [
      {"internalType": "string", "name": "name", "type": "string"},
      {"internalType": "uint256", "name": "subscriberCount", "type": "uint256"},
      {"internalType": "uint8", "name": "tier", "type": "uint8"},
      {"internalType": "uint256", "name": "registeredAt", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "", "type": "address"}
    ],
    "name": "journalistRevenue",
    "outputs": [
      {"internalType": "uint256", "name": "", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "_licensee", "type": "address"},
      {"internalType": "string", "name": "_contentId", "type": "string"}
    ],
    "name": "hasActiveLicense",
    "outputs": [
      {"internalType": "bool", "name": "", "type": "bool"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "string", "name": "_contentId", "type": "string"}
    ],
    "name": "getRepublishCount",
    "outputs": [
      {"internalType": "uint256", "name": "", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
] as const;

// Helper function to format prices
export function formatLicensePrice(tier: number, exclusive: boolean): string {
  const prices = ['0.001', '0.01', '0.05', '0.1'];
  const price = parseFloat(prices[tier]);
  return exclusive ? (price * 3).toString() : price.toString();
}

// Type definitions
export type OutletStatus = 'PENDING' | 'VERIFIED' | 'SUSPENDED' | 'BANNED';
export type OutletTier = 'BRONZE' | 'SILVER' | 'GOLD' | 'PLATINUM';
export type LicenseeTier = 'SMALL' | 'MEDIUM' | 'LARGE' | 'ENTERPRISE';

export interface OutletInfo {
  name: string;
  legalEntity: string;
  registrationNumber: string;
  jurisdiction: string;
  website: string;
  treasuryAddress: string;
  stakeAmount: bigint;
  status: OutletStatus;
  tier: OutletTier;
  credibilityScore: bigint;
  registeredAt: bigint;
  verifiedAt: bigint;
  apiKey: string;
  apiEnabled: boolean;
}

export interface LicenseeInfo {
  name: string;
  subscriberCount: bigint;
  tier: LicenseeTier;
  registeredAt: bigint;
}
