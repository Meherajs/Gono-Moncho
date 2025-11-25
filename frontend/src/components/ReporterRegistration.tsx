"use client";

import { useState, useEffect } from "react";
import { useAccount, useReadContract, useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { CONTRACT_ADDRESSES, ReporterRegistryABI, NEWSABI } from "@/lib/contracts";
import { parseEther, formatEther } from "viem";
import { useToast } from "@/context/ToastContext";

// Role enum matching contract
enum UserRole {
  NONE = 0,
  REPORTER = 1,
  ANALYZER = 2,
  VERIFIER = 3
}

// Status enum matching contract
enum ReporterStatus {
  NONE = 0,
  PENDING = 1,
  VERIFIED = 2,
  REJECTED = 3,
  SUSPENDED = 4
}

const ROLE_NAMES = {
  [UserRole.REPORTER]: "Reporter",
  [UserRole.ANALYZER]: "Analyzer",
  [UserRole.VERIFIER]: "Verifier"
};

const ROLE_STAKES = {
  [UserRole.REPORTER]: "100",
  [UserRole.ANALYZER]: "50",
  [UserRole.VERIFIER]: "25"
};

export default function ReporterRegistration() {
  const { address, isConnected } = useAccount();
  const [selectedRole, setSelectedRole] = useState<UserRole>(UserRole.REPORTER);
  const [ipfsHash, setIpfsHash] = useState("");
  const [credentials, setCredentials] = useState({
    name: "",
    organization: "",
    experience: "",
    portfolio: ""
  });
  const { showToast } = useToast();

  // Check if testing mode is enabled
  const { data: testingMode } = useReadContract({
    address: CONTRACT_ADDRESSES.ReporterRegistry,
    abi: ReporterRegistryABI,
    functionName: 'testingMode',
  });

  // Get reporter profile
  const { data: reporterData, refetch: refetchProfile } = useReadContract({
    address: CONTRACT_ADDRESSES.ReporterRegistry,
    abi: ReporterRegistryABI,
    functionName: 'reporters',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    }
  });

  // Get NEWS balance
  const { data: newsBalance } = useReadContract({
    address: CONTRACT_ADDRESSES.NEWS,
    abi: NEWSABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    }
  });

  const {
    writeContract,
    data: txHash,
    isPending: isWriting,
    error: writeError,
  } = useWriteContract();

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash: txHash,
  });

  useEffect(() => {
    if (isSuccess) {
      showToast("Transaction successful!", "success");
      refetchProfile();
      setIpfsHash("");
      setCredentials({ name: "", organization: "", experience: "", portfolio: "" });
    }
  }, [isSuccess, refetchProfile, showToast]);

  useEffect(() => {
    if (writeError) {
      showToast(writeError.message || "Transaction failed", "error");
    }
  }, [writeError, showToast]);

  const handleRegister = () => {
    if (!ipfsHash && !credentials.name) {
      showToast("Please enter your credentials or IPFS hash", "warning");
      return;
    }

    // Use IPFS hash if provided, otherwise create metadata JSON
    const metadata = ipfsHash || JSON.stringify(credentials);

    writeContract({
      address: CONTRACT_ADDRESSES.ReporterRegistry,
      abi: ReporterRegistryABI,
      functionName: 'registerReporter',
      args: [metadata, selectedRole],
    });
  };

  const handleApproveStake = () => {
    const amount = parseEther(ROLE_STAKES[selectedRole]);
    writeContract({
      address: CONTRACT_ADDRESSES.NEWS,
      abi: NEWSABI,
      functionName: 'approve',
      args: [CONTRACT_ADDRESSES.ReporterRegistry, amount],
    });
  };

  const handleStake = () => {
    const amount = parseEther(ROLE_STAKES[selectedRole]);
    writeContract({
      address: CONTRACT_ADDRESSES.ReporterRegistry,
      abi: ReporterRegistryABI,
      functionName: 'stakeTokens',
      args: [amount],
    });
  };

  if (!isConnected) {
    return (
      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-2xl font-bold mb-4">📝 Reporter Registration</h2>
        <div className="bg-yellow-50 p-4 rounded-lg border border-yellow-200">
          <p className="text-yellow-800">Please connect your wallet to register as a reporter.</p>
        </div>
      </div>
    );
  }

  const profile = reporterData as any;
  const status = profile ? Number(profile.status) : ReporterStatus.NONE;
  const role = profile ? Number(profile.role) : UserRole.NONE;
  const stakedAmount = profile ? formatEther(profile.stakedAmount) : "0";
  const isTestingMode = Boolean(testingMode);
  const newsBalanceFormatted = newsBalance ? formatEther(newsBalance) : "0";

  // Already registered
  if (status !== ReporterStatus.NONE) {
    const statusText = {
      [ReporterStatus.PENDING]: "Pending Verification",
      [ReporterStatus.VERIFIED]: "Verified ✅",
      [ReporterStatus.REJECTED]: "Rejected ❌",
      [ReporterStatus.SUSPENDED]: "Suspended ⚠️"
    }[status] || "Unknown";

    const statusColor = {
      [ReporterStatus.PENDING]: "bg-yellow-50 border-yellow-200 text-yellow-800",
      [ReporterStatus.VERIFIED]: "bg-green-50 border-green-200 text-green-800",
      [ReporterStatus.REJECTED]: "bg-red-50 border-red-200 text-red-800",
      [ReporterStatus.SUSPENDED]: "bg-orange-50 border-orange-200 text-orange-800"
    }[status] || "bg-gray-50 border-gray-200 text-gray-800";

    return (
      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-2xl font-bold mb-4">📝 Reporter Profile</h2>
        
        <div className={`p-4 rounded-lg border mb-4 ${statusColor}`}>
          <div className="flex justify-between items-center">
            <div>
              <p className="font-semibold">Status: {statusText}</p>
              <p className="text-sm">Role: {ROLE_NAMES[role as UserRole]}</p>
            </div>
            <div className="text-right">
              <p className="text-sm">Staked Amount</p>
              <p className="text-2xl font-bold">{parseFloat(stakedAmount).toFixed(2)} NEWS</p>
            </div>
          </div>
        </div>

        {profile.ipfsMetadata && (
          <div className="mb-4 p-4 bg-gray-50 rounded-lg">
            <p className="text-sm text-gray-600 mb-1">Credentials</p>
            <p className="text-sm font-mono break-all">{profile.ipfsMetadata}</p>
          </div>
        )}

        {status === ReporterStatus.PENDING && (
          <div className="bg-blue-50 p-4 rounded-lg border border-blue-200">
            <p className="text-blue-800 mb-2">⏳ Your registration is pending verification</p>
            {!isTestingMode && parseFloat(stakedAmount) < parseFloat(ROLE_STAKES[role]) && (
              <div className="mt-3">
                <p className="text-sm text-blue-700 mb-2">
                  You need to stake {ROLE_STAKES[role]} NEWS tokens to complete verification.
                </p>
                <div className="flex gap-2">
                  <button
                    onClick={handleApproveStake}
                    disabled={isWriting || isConfirming}
                    className="px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 disabled:opacity-50"
                  >
                    1. Approve
                  </button>
                  <button
                    onClick={handleStake}
                    disabled={isWriting || isConfirming}
                    className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
                  >
                    2. Stake {ROLE_STAKES[role]} NEWS
                  </button>
                </div>
              </div>
            )}
            {isTestingMode && (
              <p className="text-sm text-blue-700 mt-2">
                ✅ Testing mode enabled - No staking required!
              </p>
            )}
          </div>
        )}

        {status === ReporterStatus.VERIFIED && (
          <div className="bg-green-50 p-4 rounded-lg border border-green-200">
            <p className="text-green-800">✅ You are verified and can publish articles!</p>
            <p className="text-sm text-green-700 mt-1">
              Published Articles: {Number(profile.publishedArticles)}
            </p>
          </div>
        )}

        {status === ReporterStatus.REJECTED && (
          <div className="bg-red-50 p-4 rounded-lg border border-red-200">
            <p className="text-red-800">❌ Your registration was rejected. Please contact support.</p>
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-4">📝 Register as Reporter</h2>
      
      {isTestingMode && (
        <div className="bg-green-50 p-4 rounded-lg border border-green-200 mb-4">
          <p className="text-green-800 font-semibold">🎉 Testing Mode Enabled!</p>
          <p className="text-sm text-green-700">Registration is FREE - no staking required during testing phase.</p>
        </div>
      )}

      <p className="text-gray-600 mb-6">
        Register to become a verified reporter and start publishing news articles.
      </p>

      {/* Balance Display */}
      <div className="mb-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
        <p className="text-sm text-blue-800 mb-1">Your NEWS Balance</p>
        <p className="text-2xl font-bold text-blue-900">{parseFloat(newsBalanceFormatted).toFixed(2)} NEWS</p>
      </div>

      {/* Role Selection */}
      <div className="mb-6">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Select Your Role
        </label>
        <div className="space-y-2">
          {[UserRole.REPORTER, UserRole.ANALYZER, UserRole.VERIFIER].map((roleValue) => (
            <div
              key={roleValue}
              className={`p-4 border rounded-lg cursor-pointer transition ${
                selectedRole === roleValue
                  ? 'border-blue-500 bg-blue-50'
                  : 'border-gray-300 hover:border-blue-300'
              }`}
              onClick={() => setSelectedRole(roleValue)}
            >
              <div className="flex justify-between items-center">
                <div>
                  <p className="font-semibold">{ROLE_NAMES[roleValue]}</p>
                  <p className="text-sm text-gray-600">
                    {roleValue === UserRole.REPORTER && "Publish and report news articles"}
                    {roleValue === UserRole.ANALYZER && "Analyze article credibility"}
                    {roleValue === UserRole.VERIFIER && "Verify and score articles"}
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-sm text-gray-600">Stake Required</p>
                  <p className="font-bold text-blue-600">
                    {isTestingMode ? "FREE" : `${ROLE_STAKES[roleValue]} NEWS`}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Credentials Form */}
      <div className="mb-6 p-4 border border-gray-200 rounded-lg">
        <h3 className="font-semibold mb-3">Your Credentials</h3>
        
        {/* Option 1: IPFS Hash */}
        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            IPFS Metadata Hash (Optional)
          </label>
          <input
            type="text"
            value={ipfsHash}
            onChange={(e) => setIpfsHash(e.target.value)}
            placeholder="QmXxx... (if you already uploaded credentials to IPFS)"
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
          />
          <p className="text-xs text-gray-500 mt-1">
            If you have uploaded your credentials to IPFS, paste the hash here
          </p>
        </div>

        <div className="my-3 text-center text-gray-500">— OR —</div>

        {/* Option 2: Manual Entry */}
        <div className="space-y-3">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Full Name *
            </label>
            <input
              type="text"
              value={credentials.name}
              onChange={(e) => setCredentials({ ...credentials, name: e.target.value })}
              placeholder="Your full name"
              className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Organization
            </label>
            <input
              type="text"
              value={credentials.organization}
              onChange={(e) => setCredentials({ ...credentials, organization: e.target.value })}
              placeholder="News organization or independent"
              className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Experience (years)
            </label>
            <input
              type="text"
              value={credentials.experience}
              onChange={(e) => setCredentials({ ...credentials, experience: e.target.value })}
              placeholder="Years of experience in journalism"
              className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Portfolio/Proof URL
            </label>
            <input
              type="text"
              value={credentials.portfolio}
              onChange={(e) => setCredentials({ ...credentials, portfolio: e.target.value })}
              placeholder="Link to your previous work or credentials"
              className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>
      </div>

      {/* Register Button */}
      <button
        onClick={handleRegister}
        disabled={isWriting || isConfirming || (!ipfsHash && !credentials.name)}
        className="w-full px-6 py-3 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed font-semibold"
      >
        {isConfirming ? "Registering..." : "Register as " + ROLE_NAMES[selectedRole]}
      </button>

      {/* Info Section */}
      <div className="mt-6 bg-gray-50 p-4 rounded-lg">
        <h3 className="font-semibold text-gray-800 mb-2">ℹ️ Registration Process</h3>
        <ul className="text-sm text-gray-700 space-y-1">
          <li>1. Select your role (Reporter, Analyzer, or Verifier)</li>
          <li>2. Provide your credentials (manual entry or IPFS hash)</li>
          <li>3. Submit registration (requires blockchain transaction)</li>
          {!isTestingMode && <li>4. Stake required NEWS tokens for verification</li>}
          <li>{isTestingMode ? "4" : "5"}. Wait for admin/DAO verification</li>
          <li>{isTestingMode ? "5" : "6"}. Start publishing once verified!</li>
        </ul>
      </div>
    </div>
  );
}
