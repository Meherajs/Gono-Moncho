"use client";

import { useEffect, useState } from "react";
import { useWriteContract, useWaitForTransactionReceipt, useReadContract } from "wagmi";
import { VerificationABI, CONTRACT_ADDRESSES } from "@/lib/contracts";
import { useArticles } from "@/context/ArticleContext";

type Props = {
  articleId: number;
  contentHash?: string;
  currentScore?: number;
  status?: "Verified" | "Pending";
  statusLabel?: string; // Detailed status label
};

export default function VerificationSection({
  articleId,
  contentHash,
  currentScore,
  status,
  statusLabel,
}: Props) {
  const { refreshArticles, refreshArticleByHash } = useArticles();
  const [toast, setToast] = useState<{ message: string; type: "success" | "error" } | null>(null);
  
  // Fetch news item details from contract (includes verifierScores array)
  const { data: newsItemData, refetch: refetchNewsItem } = useReadContract({
    address: CONTRACT_ADDRESSES.Verification,
    abi: VerificationABI,
    functionName: 'newsItems',
    args: contentHash ? [contentHash] : undefined,
    query: {
      enabled: !!contentHash,
    }
  });

  const {
    writeContract,
    data: txHash,
    isPending: isWriting,
    error: writeError,
  } = useWriteContract();
  const { isLoading: isConfirming, isSuccess, isError: isConfirmError } = useWaitForTransactionReceipt({
    hash: txHash,
  });

  useEffect(() => {
    if (isSuccess && contentHash) {
      setToast({ message: "Transaction confirmed! Article verification updated.", type: "success" });
      // Refetch scores and article data
      refetchNewsItem();
      refreshArticleByHash(contentHash).catch(() => {
        refreshArticles();
      });
      setTimeout(() => setToast(null), 5000);
    } else if (isSuccess) {
      setToast({ message: "Transaction confirmed! Article verification updated.", type: "success" });
      refreshArticles();
      setTimeout(() => setToast(null), 5000);
    }
  }, [isSuccess, contentHash, refreshArticles, refreshArticleByHash, refetchNewsItem]);

  useEffect(() => {
    if (writeError || isConfirmError) {
      setToast({ 
        message: writeError?.message || "Transaction failed. Please try again.", 
        type: "error" 
      });
      setTimeout(() => setToast(null), 5000);
    }
  }, [writeError, isConfirmError]);

  const disabled = !contentHash || isWriting || isConfirming;

  const handleVerify = () => {
    if (!contentHash) return;
    writeContract({
      address: CONTRACT_ADDRESSES.Verification,
      abi: VerificationABI,
      functionName: "addVerifierScore",
      args: [contentHash, BigInt(100)], // Score 100 = positive verification
    });
  };

  const handleFlag = () => {
    if (!contentHash) return;
    writeContract({
      address: CONTRACT_ADDRESSES.Verification,
      abi: VerificationABI,
      functionName: "addVerifierScore",
      args: [contentHash, BigInt(0)], // Score 0 = negative/rejected
    });
  };

  const getStatusColor = (label?: string) => {
    if (!label) return "text-gray-600";
    if (label.includes("Human Verified")) return "text-green-600";
    if (label.includes("AI Verified")) return "text-blue-600";
    if (label.includes("Disputed")) return "text-red-600";
    return "text-yellow-600";
  };

  const getStatusText = (statusCode?: number): string => {
    if (!statusCode) return "Pending";
    switch (statusCode) {
      case 0: return "Pending";
      case 1: return "AI Verified";
      case 2: return "Human Verified";
      case 3: return "Disputed";
      default: return "Unknown";
    }
  };

  // Extract data from contract response
  // newsItems returns: [reporter, arweaveHash, analyzerScores[], verifierScores[], status, credibilityScore]
  const verifierScoresArray = newsItemData ? (newsItemData[3] as bigint[]) : [];
  const verificationStatus = newsItemData ? Number(newsItemData[4]) : 0;
  const contractCredibility = newsItemData ? Number(newsItemData[5]) : 0;
  
  // Count positive (>50) vs negative (<=50) scores
  const positiveVotes = verifierScoresArray.filter(score => Number(score) > 50).length;
  const negativeVotes = verifierScoresArray.filter(score => Number(score) <= 50).length;
  const totalVotes = verifierScoresArray.length;

  return (
    <div className="p-8 lg:p-12">
      {toast && (
        <div
          className={`mb-6 p-4 rounded-xl shadow-lg animate-slide-down ${
            toast.type === "success"
              ? "bg-gradient-to-r from-green-50 to-emerald-50 text-green-800 border-2 border-green-200"
              : "bg-gradient-to-r from-red-50 to-rose-50 text-red-800 border-2 border-red-200"
          }`}
        >
          <div className="flex items-center gap-2">
            <span className="text-2xl">{toast.type === "success" ? "✅" : "❌"}</span>
            <span className="font-medium">{toast.message}</span>
          </div>
        </div>
      )}
      
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-3">
          <span className="text-3xl">🗳️</span>
          <h3 className="text-3xl font-bold text-gray-900">Cast Your Vote</h3>
        </div>
        <p className="text-gray-600 text-base leading-relaxed">
          Help verify this article&apos;s authenticity. Your vote directly influences the credibility score.
        </p>
      </div>

      {/* Vote Statistics Card */}
      <div className="grid md:grid-cols-3 gap-4 mb-8">
        <div className="bg-gradient-to-br from-green-50 to-emerald-50 p-6 rounded-xl border-2 border-green-200 shadow-sm">
          <div className="text-sm font-semibold text-green-700 mb-1">✓ Authentic Votes</div>
          <div className="text-3xl font-black text-green-700">{positiveVotes}</div>
        </div>
        <div className="bg-gradient-to-br from-red-50 to-rose-50 p-6 rounded-xl border-2 border-red-200 shadow-sm">
          <div className="text-sm font-semibold text-red-700 mb-1">✗ Disputed Votes</div>
          <div className="text-3xl font-black text-red-700">{negativeVotes}</div>
        </div>
        <div className="bg-gradient-to-br from-blue-50 to-indigo-50 p-6 rounded-xl border-2 border-blue-200 shadow-sm">
          <div className="text-sm font-semibold text-blue-700 mb-1">📊 Total Votes</div>
          <div className="text-3xl font-black text-blue-700">{totalVotes}</div>
        </div>
      </div>

      {/* Approval Rate Progress Bar */}
      {totalVotes > 0 && (
        <div className="mb-8 p-6 bg-gradient-to-r from-gray-50 to-gray-100 rounded-xl border border-gray-200">
          <div className="flex items-center justify-between mb-3">
            <span className="text-sm font-bold text-gray-700">Community Approval Rate</span>
            <span className="text-lg font-black text-gray-900">
              {Math.round((positiveVotes / totalVotes) * 100)}%
            </span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-4 overflow-hidden shadow-inner">
            <div
              className="h-full bg-gradient-to-r from-green-500 to-emerald-500 rounded-full transition-all duration-1000 ease-out shadow-glow"
              style={{ width: `${(positiveVotes / totalVotes) * 100}%` }}
            ></div>
          </div>
        </div>
      )}

      {/* Voting Buttons */}
      <div className="grid md:grid-cols-2 gap-4 mb-8">
        <button
          onClick={handleVerify}
          disabled={disabled}
          className="group relative bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 disabled:from-gray-300 disabled:to-gray-400 text-white font-bold py-5 px-6 rounded-xl transition-all duration-300 shadow-lg hover:shadow-2xl hover:-translate-y-1 disabled:hover:translate-y-0 disabled:cursor-not-allowed overflow-hidden"
        >
          <span className="relative z-10 flex items-center justify-center gap-2 text-lg">
            <span className="text-2xl">✓</span>
            {isWriting || isConfirming ? "Processing..." : "Confirm Authentic"}
          </span>
          <span className="absolute inset-0 bg-gradient-to-r from-green-400 to-emerald-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
        </button>
        <button
          onClick={handleFlag}
          disabled={disabled}
          className="group relative bg-gradient-to-r from-red-500 to-rose-600 hover:from-red-600 hover:to-rose-700 disabled:from-gray-300 disabled:to-gray-400 text-white font-bold py-5 px-6 rounded-xl transition-all duration-300 shadow-lg hover:shadow-2xl hover:-translate-y-1 disabled:hover:translate-y-0 disabled:cursor-not-allowed overflow-hidden"
        >
          <span className="relative z-10 flex items-center justify-center gap-2 text-lg">
            <span className="text-2xl">✗</span>
            {isWriting || isConfirming ? "Processing..." : "Flag as Misinformation"}
          </span>
          <span className="absolute inset-0 bg-gradient-to-r from-red-400 to-rose-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
        </button>
      </div>

      {/* Info Message */}
      {!contentHash && (
        <div className="p-5 bg-yellow-50 border-2 border-yellow-200 rounded-xl">
          <div className="flex items-start gap-3">
            <span className="text-2xl">⚠️</span>
            <div>
              <p className="font-semibold text-yellow-800 mb-1">Content Reference Missing</p>
              <p className="text-sm text-yellow-700">
                This submission does not have a content reference yet. Please try again after publishing reaches the network.
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}