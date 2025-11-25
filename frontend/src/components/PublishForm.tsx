"use client";

import { useState, useEffect, useRef } from 'react';
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { VerificationABI, CONTRACT_ADDRESSES } from '@/lib/contracts';
import { useArticles } from '@/context/ArticleContext';
import { useToast } from '@/context/ToastContext';
import { keccak256, stringToBytes } from 'viem';

export default function PublishForm() {
  const [headline, setHeadline] = useState('');
  const [content, setContent] = useState('');
  const [videoFile, setVideoFile] = useState<File | null>(null);
  const hasAddedArticle = useRef(false);
  const { showToast } = useToast();

  const { addArticle, refreshArticles } = useArticles();
  const { data: hash, writeContract, error: writeError } = useWriteContract();
  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({ hash });

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files) {
      setVideoFile(event.target.files[0]);
    }
  };

  useEffect(() => {
    if (isConfirmed && !hasAddedArticle.current) {
      hasAddedArticle.current = true;
      
      let videoUrl;
      if (videoFile) {
        videoUrl = URL.createObjectURL(videoFile);
      }

      const payload = JSON.stringify({
        headline,
        content,
        createdAt: new Date().toISOString(),
      });
      const contentHash = keccak256(stringToBytes(payload));
      
      addArticle({ headline, summary: content, body: content, videoUrl, contentHash });
      refreshArticles();
      
      showToast("Article published successfully!", "success");
      
      setHeadline('');
      setContent('');
      setVideoFile(null);
    }
  }, [isConfirmed, headline, content, videoFile, addArticle, refreshArticles, showToast]);

  useEffect(() => {
    if (writeError) {
      showToast(writeError.message || "Failed to publish article. Please try again.", "error");
    }
  }, [writeError, showToast]);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    if (!headline || !content) {
      showToast("Please fill out all required fields.", "warning");
      return;
    }
    hasAddedArticle.current = false;
    
    const payload = JSON.stringify({
      headline,
      content,
      createdAt: new Date().toISOString(),
    });
    const contentHash = keccak256(stringToBytes(payload));
    
    showToast("Publishing article to blockchain...", "info");
    
    writeContract({
      address: CONTRACT_ADDRESSES.Verification,
      abi: VerificationABI,
      functionName: 'publishNews',
      args: [contentHash],
    });
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-4">✍️ Publish Article</h2>
      <p className="text-gray-600 mb-6">
        Share your story with the world. Your article will be published on-chain and stored permanently.
      </p>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Headline */}
        <div>
          <label htmlFor="headline" className="block text-sm font-medium text-gray-700 mb-2">
            Headline *
          </label>
          <input
            id="headline"
            type="text"
            value={headline}
            onChange={(e) => setHeadline(e.target.value)}
            placeholder="Enter a compelling headline..."
            required
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-lg font-semibold"
          />
        </div>

        {/* Content */}
        <div>
          <label htmlFor="content" className="block text-sm font-medium text-gray-700 mb-2">
            Article Content *
          </label>
          <textarea
            id="content"
            value={content}
            onChange={(e) => setContent(e.target.value)}
            placeholder="Write your article here... Be detailed and factual."
            required
            rows={12}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-y"
          />
          <p className="text-xs text-gray-500 mt-1">
            {content.length} characters
          </p>
        </div>

        {/* Optional Video */}
        <div>
          <label htmlFor="video" className="block text-sm font-medium text-gray-700 mb-2">
            Video/Media (Optional)
          </label>
          <input
            id="video"
            type="file"
            onChange={handleFileChange}
            accept="video/*,image/*"
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
          />
          {videoFile && (
            <p className="text-sm text-green-600 mt-2">
              ✓ Selected: {videoFile.name}
            </p>
          )}
        </div>

        {/* Submit Button */}
        <div className="flex gap-4">
          <button
            type="submit"
            disabled={isConfirming || !headline || !content}
            className="flex-1 px-6 py-3 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-lg hover:from-blue-700 hover:to-blue-800 disabled:opacity-50 disabled:cursor-not-allowed font-semibold shadow-lg hover:shadow-xl transition-all"
          >
            {isConfirming ? (
              <span className="flex items-center justify-center gap-2">
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                Publishing...
              </span>
            ) : (
              "📰 Publish Article"
            )}
          </button>
          <button
            type="button"
            onClick={() => {
              setHeadline('');
              setContent('');
              setVideoFile(null);
            }}
            className="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-all font-medium"
          >
            Clear
          </button>
        </div>
      </form>

      {/* Info Box */}
      <div className="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
        <h3 className="font-semibold text-blue-800 mb-2">📋 Publishing Guidelines</h3>
        <ul className="text-sm text-blue-700 space-y-1">
          <li>• Be accurate and factual in your reporting</li>
          <li>• Cite sources when possible</li>
          <li>• Avoid misleading or sensational headlines</li>
          <li>• Your article will be verified by the community</li>
          <li>• Quality reporting earns CRED reputation tokens</li>
        </ul>
      </div>

      {/* Tips */}
      <div className="mt-4 p-4 bg-gray-50 rounded-lg">
        <h3 className="font-semibold text-gray-800 mb-2">💡 Tips for Success</h3>
        <ul className="text-sm text-gray-700 space-y-1">
          <li>• Upload supporting media to Arweave/IPFS first</li>
          <li>• Include timestamps and location details</li>
          <li>• Provide context and background information</li>
          <li>• Proofread before publishing</li>
        </ul>
      </div>
    </div>
  );
}
