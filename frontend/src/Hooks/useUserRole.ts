import { useAccount } from 'wagmi';

export function useUserRole() {
  const { isConnected } = useAccount();

  // If the user's wallet is not connected, they cannot have a role.
  if (!isConnected) {
    return { 
      isJournalist: false, 
      isAnalyzer: false, 
      isLoading: false 
    };
  }

  // If the wallet IS connected, we will return our mock roles for the prototype.
  // This is now synchronous and will be instant.
  return { 
    isJournalist: true, 
    isAnalyzer: true, 
    isLoading: false 
  };
}