"use client";

import { useState } from "react";
import { useAccount, useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { CONTRACT_ADDRESSES, ReporterRegistryABI } from "@/lib/contracts";
import { useToast } from "@/context/ToastContext";

export default function DemoHelper() {
  const { address } = useAccount();
  const [isOpen, setIsOpen] = useState(false);
  const { showToast } = useToast();

  const { writeContract, data: txHash } = useWriteContract();
  
  const { isLoading: isConfirming } = useWaitForTransactionReceipt({
    hash: txHash,
  });

  const autoVerifyReporter = () => {
    if (!address) {
      showToast("Please connect your wallet first", "error");
      return;
    }

    try {
      writeContract({
        address: CONTRACT_ADDRESSES.ReporterRegistry,
        abi: ReporterRegistryABI,
        functionName: 'verifyReporter',
        args: [address, true], // Auto-approve
      });
      
      showToast("Auto-verification request sent!", "success");
    } catch (error) {
      showToast("Failed to auto-verify: " + (error as Error).message, "error");
    }
  };

  if (CONTRACT_ADDRESSES.ReporterRegistry === '0x0000000000000000000000000000000000000000') {
    return null; // Don't show if contract not deployed
  }

  return (
    <>
      {/* Demo Helper Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="fixed bottom-4 right-4 bg-gradient-to-r from-purple-600 to-blue-600 text-white px-4 py-2 rounded-full shadow-lg hover:shadow-xl transition-all z-50 flex items-center gap-2"
      >
        🎯 Demo Helper
      </button>

      {/* Demo Helper Panel */}
      {isOpen && (
        <div className="fixed bottom-20 right-4 bg-white dark:bg-gray-800 rounded-lg shadow-2xl p-6 w-80 z-50 border border-gray-200 dark:border-gray-700">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-bold">Demo Helper</h3>
            <button
              onClick={() => setIsOpen(false)}
              className="text-gray-500 hover:text-gray-700"
            >
              ✕
            </button>
          </div>

          <div className="space-y-4">
            <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-3">
              <p className="text-sm text-yellow-800 dark:text-yellow-200 mb-2">
                <strong>🎯 Testing Mode Active</strong>
              </p>
              <p className="text-xs text-yellow-700 dark:text-yellow-300">
                All operations are FREE. No tokens required!
              </p>
            </div>

            <div className="space-y-2">
              <h4 className="font-semibold text-sm">Quick Actions:</h4>
              
              <button
                onClick={autoVerifyReporter}
                disabled={isConfirming}
                className="w-full bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-sm"
              >
                {isConfirming ? "Verifying..." : "✓ Auto-Verify Me as Reporter"}
              </button>

              <p className="text-xs text-gray-600 dark:text-gray-400">
                Click this after registering to instantly verify yourself for the demo.
              </p>
            </div>

            <div className="border-t border-gray-200 dark:border-gray-700 pt-3 mt-3">
              <h4 className="font-semibold text-sm mb-2">Demo Flow:</h4>
              <ol className="text-xs text-gray-600 dark:text-gray-400 space-y-1 list-decimal list-inside">
                <li>Register as Reporter (FREE)</li>
                <li>Click "Auto-Verify" button above</li>
                <li>Upload content to Arweave</li>
                <li>Publish article (FREE testnet)</li>
                <li>Vote on articles (FREE testnet)</li>
              </ol>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
