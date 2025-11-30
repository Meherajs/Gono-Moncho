import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther } from 'viem';
import {
  NEWS_OUTLET_REGISTRY_ADDRESS,
  NEWS_OUTLET_REGISTRY_ABI,
  ORGANIZATION_STAKING_ADDRESS,
  ORGANIZATION_STAKING_ABI,
  DECENTRALIZED_PUBLISHING_API_ADDRESS,
  DECENTRALIZED_PUBLISHING_API_ABI,
  SYNDICATION_LICENSING_ADDRESS,
  SYNDICATION_LICENSING_ABI,
} from '@/lib/contracts/organizationFeatures';

// News Outlet Registry Hooks
export function useOutletInfo(address: `0x${string}` | undefined) {
  return useReadContract({
    address: NEWS_OUTLET_REGISTRY_ADDRESS,
    abi: NEWS_OUTLET_REGISTRY_ABI,
    functionName: 'outlets',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });
}

export function useIsAffiliatedJournalist(
  outletAddress: `0x${string}` | undefined,
  journalistAddress: `0x${string}` | undefined
) {
  return useReadContract({
    address: NEWS_OUTLET_REGISTRY_ADDRESS,
    abi: NEWS_OUTLET_REGISTRY_ABI,
    functionName: 'isAffiliatedJournalist',
    args: outletAddress && journalistAddress ? [outletAddress, journalistAddress] : undefined,
    query: {
      enabled: !!outletAddress && !!journalistAddress,
    },
  });
}

export function useRegisterOutlet() {
  const { writeContract, data: hash, isPending, error } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const register = (params: {
    name: string;
    legalEntity: string;
    registrationNumber: string;
    jurisdiction: string;
    website: string;
    treasuryAddress: `0x${string}`;
    stakeAmount: string;
  }) => {
    writeContract({
      address: NEWS_OUTLET_REGISTRY_ADDRESS,
      abi: NEWS_OUTLET_REGISTRY_ABI,
      functionName: 'registerOutlet',
      args: [
        params.name,
        params.legalEntity,
        params.registrationNumber,
        params.jurisdiction,
        params.website,
        params.treasuryAddress,
      ],
      value: parseEther(params.stakeAmount),
    });
  };

  return { register, isPending, isConfirming, isSuccess, error };
}

export function useAffiliateJournalist() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const affiliate = (journalistAddress: `0x${string}`, role: string) => {
    writeContract({
      address: NEWS_OUTLET_REGISTRY_ADDRESS,
      abi: NEWS_OUTLET_REGISTRY_ABI,
      functionName: 'affiliateJournalist',
      args: [journalistAddress, role],
    });
  };

  return { affiliate, isPending, isConfirming, isSuccess };
}

// Organization Staking Hooks
export function useOrganizationTotalStake(address: `0x${string}` | undefined) {
  return useReadContract({
    address: ORGANIZATION_STAKING_ADDRESS,
    abi: ORGANIZATION_STAKING_ABI,
    functionName: 'organizationTotalStake',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });
}

export function useTotalJournalistBacking(journalistAddress: `0x${string}` | undefined) {
  return useReadContract({
    address: ORGANIZATION_STAKING_ADDRESS,
    abi: ORGANIZATION_STAKING_ABI,
    functionName: 'getTotalJournalistBacking',
    args: journalistAddress ? [journalistAddress] : undefined,
    query: {
      enabled: !!journalistAddress,
    },
  });
}

export function useDepositOrganizationStake() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const deposit = (amount: string) => {
    writeContract({
      address: ORGANIZATION_STAKING_ADDRESS,
      abi: ORGANIZATION_STAKING_ABI,
      functionName: 'depositOrganizationStake',
      args: [parseEther(amount)],
    });
  };

  return { deposit, isPending, isConfirming, isSuccess };
}

export function useAllocateToJournalist() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const allocate = (journalistAddress: `0x${string}`, amount: string) => {
    writeContract({
      address: ORGANIZATION_STAKING_ADDRESS,
      abi: ORGANIZATION_STAKING_ABI,
      functionName: 'allocateToJournalist',
      args: [journalistAddress, parseEther(amount)],
    });
  };

  return { allocate, isPending, isConfirming, isSuccess };
}

// Decentralized Publishing API Hooks
export function useOutletAPIKey(address: `0x${string}` | undefined) {
  return useReadContract({
    address: DECENTRALIZED_PUBLISHING_API_ADDRESS,
    abi: DECENTRALIZED_PUBLISHING_API_ABI,
    functionName: 'outletAPIKeys',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });
}

export function useRateLimitStatus(address: `0x${string}` | undefined) {
  return useReadContract({
    address: DECENTRALIZED_PUBLISHING_API_ADDRESS,
    abi: DECENTRALIZED_PUBLISHING_API_ABI,
    functionName: 'getRateLimitStatus',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });
}

export function useGenerateAPIKey() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const generate = (outletAddress: `0x${string}`) => {
    writeContract({
      address: DECENTRALIZED_PUBLISHING_API_ADDRESS,
      abi: DECENTRALIZED_PUBLISHING_API_ABI,
      functionName: 'generateAPIKey',
      args: [outletAddress],
    });
  };

  return { generate, isPending, isConfirming, isSuccess };
}

export function useSubmitArticle() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const submit = (params: {
    apiKey: string;
    author: `0x${string}`;
    title: string;
    contentHash: string;
    category: string;
  }) => {
    writeContract({
      address: DECENTRALIZED_PUBLISHING_API_ADDRESS,
      abi: DECENTRALIZED_PUBLISHING_API_ABI,
      functionName: 'submitArticle',
      args: [params.apiKey, params.author, params.title, params.contentHash, params.category],
    });
  };

  return { submit, isPending, isConfirming, isSuccess };
}

// Syndication Licensing Hooks
export function useLicenseeInfo(address: `0x${string}` | undefined) {
  return useReadContract({
    address: SYNDICATION_LICENSING_ADDRESS,
    abi: SYNDICATION_LICENSING_ABI,
    functionName: 'licensees',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });
}

export function useJournalistRevenue(address: `0x${string}` | undefined) {
  return useReadContract({
    address: SYNDICATION_LICENSING_ADDRESS,
    abi: SYNDICATION_LICENSING_ABI,
    functionName: 'journalistRevenue',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });
}

export function useHasActiveLicense(
  licenseeAddress: `0x${string}` | undefined,
  contentId: string | undefined
) {
  return useReadContract({
    address: SYNDICATION_LICENSING_ADDRESS,
    abi: SYNDICATION_LICENSING_ABI,
    functionName: 'hasActiveLicense',
    args: licenseeAddress && contentId ? [licenseeAddress, contentId] : undefined,
    query: {
      enabled: !!licenseeAddress && !!contentId,
    },
  });
}

export function useRegisterLicensee() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const register = (name: string, subscriberCount: string) => {
    writeContract({
      address: SYNDICATION_LICENSING_ADDRESS,
      abi: SYNDICATION_LICENSING_ABI,
      functionName: 'registerLicensee',
      args: [name, BigInt(subscriberCount)],
    });
  };

  return { register, isPending, isConfirming, isSuccess };
}

export function usePurchaseLicense() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const purchase = (contentId: string, exclusive: boolean, price: string) => {
    writeContract({
      address: SYNDICATION_LICENSING_ADDRESS,
      abi: SYNDICATION_LICENSING_ABI,
      functionName: 'purchaseLicense',
      args: [contentId, exclusive],
      value: parseEther(price),
    });
  };

  return { purchase, isPending, isConfirming, isSuccess };
}

export function useWithdrawJournalistRevenue() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const withdraw = () => {
    writeContract({
      address: SYNDICATION_LICENSING_ADDRESS,
      abi: SYNDICATION_LICENSING_ABI,
      functionName: 'withdrawJournalistRevenue',
      args: [],
    });
  };

  return { withdraw, isPending, isConfirming, isSuccess };
}

export function useRecordRepublish() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const record = (contentId: string, republishUrl: string) => {
    writeContract({
      address: SYNDICATION_LICENSING_ADDRESS,
      abi: SYNDICATION_LICENSING_ABI,
      functionName: 'recordRepublish',
      args: [contentId, republishUrl],
    });
  };

  return { record, isPending, isConfirming, isSuccess };
}
