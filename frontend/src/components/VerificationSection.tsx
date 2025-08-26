"use client";

import { useWriteContract } from 'wagmi';
import { gonoMonchoABI } from '@/lib/abi';

const contractAddress = '0x0000000000000000000000000000000000000000';

// The component now accepts the article's ID as a prop
export default function VerificationSection({ articleId }: { articleId: number }) {
  const { writeContract } = useWriteContract();

  const handleVerify = () => {
    writeContract({
      address: contractAddress,
      abi: gonoMonchoABI,
      functionName: 'confirmAuthenticity',
      args: [BigInt(articleId)], // We convert the ID to BigInt for the smart contract
    });
  };

  const handleFlag = () => {
    writeContract({
      address: contractAddress,
      abi: gonoMonchoABI,
      functionName: 'flagAsMisinformation',
      args: [BigInt(articleId)],
    });
  };

  return (
    <div className="mt-8 pt-6 border-t">
      <h3 className="text-2xl font-bold mb-4">Cast Your Vote</h3>
      <p className="text-gray-600 mb-4">
        As a verified user, your vote contributes to the article's reputation score. Please review carefully before voting.
      </p>
      <div className="flex items-center gap-4">
        <button
          onClick={handleVerify}
          className="px-6 py-2 border rounded-md font-medium text-white bg-green-600 hover:bg-green-700"
        >
          Confirm as Authentic
        </button>
        <button
          onClick={handleFlag}
          className="px-6 py-2 border rounded-md font-medium text-white bg-red-600 hover:bg-red-700"
        >
          Flag as Misinformation
        </button>
      </div>
    </div>
  );
}