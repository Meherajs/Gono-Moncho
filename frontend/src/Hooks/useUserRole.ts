import { useAccount, useReadContract } from 'wagmi';
import { CONTRACT_ADDRESSES, NewsStakingABI, CREDABI } from '@/lib/contracts';

export function useUserRole() {
  const { address, isConnected } = useAccount();

  // Check if user has staked NEWS tokens (makes them a journalist)
  const { data: stakeData, isLoading: isLoadingStake } = useReadContract({
    address: CONTRACT_ADDRESSES.NewsStaking,
    abi: NewsStakingABI,
    functionName: 'stakes',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address && isConnected,
    }
  });

  // Check if user has CRED tokens (makes them a verifier/analyzer)
  const { data: credBalance, isLoading: isLoadingCred } = useReadContract({
    address: CONTRACT_ADDRESSES.CRED,
    abi: CREDABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address && isConnected,
    }
  });

  if (!isConnected) {
    return { 
      isJournalist: false, 
      isAnalyzer: false, 
      isLoading: false 
    };
  }

  const isLoading = isLoadingStake || isLoadingCred;
  
  // User is a journalist if they have staked NEWS tokens
  const stakedAmount = stakeData ? (stakeData[0] as bigint) : BigInt(0);
  const isJournalist = stakedAmount > BigInt(0);
  
  // User is an analyzer/verifier if they have CRED tokens
  const credAmount = credBalance || BigInt(0);
  const isAnalyzer = credAmount > BigInt(0);

  return { 
    isJournalist, 
    isAnalyzer, 
    isLoading 
  };
}