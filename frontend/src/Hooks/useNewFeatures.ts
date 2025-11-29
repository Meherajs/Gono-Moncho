import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { 
  TokenEconomicsABI, 
  ProofOfHumanityABI, 
  ZeroKnowledgePublishingABI,
  CREDRewardDistributorABI,
  JournalisticIntegrityCouncilABI,
  ReputationWeightedVotingABI,
  CONTRACT_ADDRESSES 
} from '@/lib/contracts/newFeatures';

// Token Economics Hooks
export const useTokenEconomicsStats = () => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.TokenEconomics as `0x${string}`,
    abi: TokenEconomicsABI,
    functionName: 'getStats',
  });
};

export const useCollectRevenue = () => {
  const { data: hash, writeContract, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const collectSyndicationRevenue = (amount: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.TokenEconomics as `0x${string}`,
      abi: TokenEconomicsABI,
      functionName: 'collectSyndicationRevenue',
      args: [amount],
      value: amount,
    });
  };

  const collectAnalyticsRevenue = (amount: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.TokenEconomics as `0x${string}`,
      abi: TokenEconomicsABI,
      functionName: 'collectAnalyticsRevenue',
      args: [amount],
      value: amount,
    });
  };

  return {
    collectSyndicationRevenue,
    collectAnalyticsRevenue,
    isPending: isPending || isConfirming,
    isSuccess,
    hash,
  };
};

// Proof of Humanity Hooks
export const useIsVerifiedHuman = (address?: `0x${string}`) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.ProofOfHumanity as `0x${string}`,
    abi: ProofOfHumanityABI,
    functionName: 'isVerified',
    args: address ? [address] : undefined,
  });
};

export const useSocialMetrics = (address?: `0x${string}`) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.ProofOfHumanity as `0x${string}`,
    abi: ProofOfHumanityABI,
    functionName: 'getSocialMetrics',
    args: address ? [address] : undefined,
  });
};

export const useSubmitProof = () => {
  const { data: hash, writeContract, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const submitProof = (
    contextHash: `0x${string}`,
    confidenceScore: number,
    connections: `0x${string}`[]
  ) => {
    writeContract({
      address: CONTRACT_ADDRESSES.ProofOfHumanity as `0x${string}`,
      abi: ProofOfHumanityABI,
      functionName: 'submitProof',
      args: [contextHash, confidenceScore, connections],
    });
  };

  return { submitProof, isPending: isPending || isConfirming, isSuccess, hash };
};

// Zero-Knowledge Publishing Hooks
export const useCommitAnonymousPublish = () => {
  const { data: hash, writeContract, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess, data } = useWaitForTransactionReceipt({ hash });

  const commitPublish = (commitment: `0x${string}`, category: string) => {
    writeContract({
      address: CONTRACT_ADDRESSES.ZeroKnowledgePublishing as `0x${string}`,
      abi: ZeroKnowledgePublishingABI,
      functionName: 'commitAnonymousPublish',
      args: [commitment, category],
    });
  };

  return { commitPublish, isPending: isPending || isConfirming, isSuccess, hash, data };
};

export const useRevealContent = () => {
  const { data: hash, writeContract, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const revealContent = (
    commitId: bigint,
    contentHash: `0x${string}`,
    author: `0x${string}`
  ) => {
    writeContract({
      address: CONTRACT_ADDRESSES.ZeroKnowledgePublishing as `0x${string}`,
      abi: ZeroKnowledgePublishingABI,
      functionName: 'revealContent',
      args: [commitId, contentHash, author],
    });
  };

  return { revealContent, isPending: isPending || isConfirming, isSuccess, hash };
};

export const useGetCommitment = (commitId?: bigint) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.ZeroKnowledgePublishing as `0x${string}`,
    abi: ZeroKnowledgePublishingABI,
    functionName: 'getCommitment',
    args: commitId !== undefined ? [commitId] : undefined,
  });
};

// CRED Reward Distributor Hooks
export const useUserRewardStats = (address?: `0x${string}`) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.CREDRewardDistributor as `0x${string}`,
    abi: CREDRewardDistributorABI,
    functionName: 'getUserRewardStats',
    args: address ? [address] : undefined,
  });
};

export const useClaimStakingRewards = () => {
  const { data: hash, writeContract, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const claimRewards = () => {
    writeContract({
      address: CONTRACT_ADDRESSES.CREDRewardDistributor as `0x${string}`,
      abi: CREDRewardDistributorABI,
      functionName: 'claimStakingRewards',
    });
  };

  return { claimRewards, isPending: isPending || isConfirming, isSuccess, hash };
};

// Journalistic Integrity Council Hooks
export const useRequestReview = () => {
  const { data: hash, writeContract, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const requestReview = (
    contentHash: `0x${string}`,
    specialty: string,
    reason: string
  ) => {
    writeContract({
      address: CONTRACT_ADDRESSES.JournalisticIntegrityCouncil as `0x${string}`,
      abi: JournalisticIntegrityCouncilABI,
      functionName: 'requestReview',
      args: [contentHash, specialty, reason],
    });
  };

  return { requestReview, isPending: isPending || isConfirming, isSuccess, hash };
};

export const useCastVote = () => {
  const { data: hash, writeContract, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const castVote = (reviewId: bigint, approve: boolean, feedback: string) => {
    writeContract({
      address: CONTRACT_ADDRESSES.JournalisticIntegrityCouncil as `0x${string}`,
      abi: JournalisticIntegrityCouncilABI,
      functionName: 'castVote',
      args: [reviewId, approve, feedback],
    });
  };

  return { castVote, isPending: isPending || isConfirming, isSuccess, hash };
};

export const useGetReview = (reviewId?: bigint) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.JournalisticIntegrityCouncil as `0x${string}`,
    abi: JournalisticIntegrityCouncilABI,
    functionName: 'getReview',
    args: reviewId !== undefined ? [reviewId] : undefined,
  });
};

// Reputation Weighted Voting Hooks
export const useVotingPower = (
  voter?: `0x${string}`,
  stakingContract?: `0x${string}`,
  credToken?: `0x${string}`
) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.ReputationWeightedVoting as `0x${string}`,
    abi: ReputationWeightedVotingABI,
    functionName: 'calculateVotingPower',
    args: voter && stakingContract && credToken 
      ? [voter, stakingContract, credToken, 50n, 50n]
      : undefined,
  });
};

export const useVotingPowerBreakdown = (
  voter?: `0x${string}`,
  stakingContract?: `0x${string}`,
  credToken?: `0x${string}`
) => {
  return useReadContract({
    address: CONTRACT_ADDRESSES.ReputationWeightedVoting as `0x${string}`,
    abi: ReputationWeightedVotingABI,
    functionName: 'getVotingPowerBreakdown',
    args: voter && stakingContract && credToken
      ? [voter, stakingContract, credToken, 50n, 50n]
      : undefined,
  });
};
