"use client";

import { useState, useEffect, useRef } from 'react';
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { gonoMonchoABI } from '@/lib/abi';
import { parseEther } from 'viem';
import { useArticles } from '@/context/ArticleContext';
import { useRouter } from 'next/navigation';

const contractAddress = '0x0000000000000000000000000000000000000000';

export default function PublishPage() {
  const [headline, setHeadline] = useState('');
  const [content, setContent] = useState('');
  const [videoFile, setVideoFile] = useState<File | null>(null);
  const router = useRouter();
  const hasAddedArticle = useRef(false);

  const { addArticle } = useArticles();
  const { data: hash, writeContract } = useWriteContract();
  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({ hash });

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files) {
      setVideoFile(event.target.files[0]);
    }
  };

  useEffect(() => {
    if (isConfirmed && !hasAddedArticle.current) {
      hasAddedArticle.current = true;
      
      // --- NEW LOGIC HERE ---
      let videoUrl;
      if (videoFile) {
        // Create a temporary local URL for the selected video file
        videoUrl = URL.createObjectURL(videoFile);
      }

      // Add the article with the new videoUrl to our global state
      addArticle({ headline, summary: content, videoUrl });
      
      setHeadline('');
      setContent('');
      setVideoFile(null);
      
      setTimeout(() => {
        router.push('/');
      }, 1500);
    }
  }, [isConfirmed, headline, content, videoFile, addArticle, router]);


  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    if (!headline || !content) {
      alert("Please fill out all text fields.");
      return;
    }
    hasAddedArticle.current = false;
    
    writeContract({
      address: contractAddress,
      abi: gonoMonchoABI,
      functionName: 'publishArticle',
      args: [headline, content],
      value: parseEther('0.00001'),
    });
  };

  return (
    // ... JSX is unchanged, no need to copy this part ...
    <div className="bg-gray-50 min-h-screen"><main className="container mx-auto p-4 sm:p-6 lg:p-8"><h1 className="text-3xl font-bold text-gray-900 mb-6">Publish a New Article</h1><div className="bg-white p-8 rounded-lg shadow-md"><form className="space-y-6" onSubmit={handleSubmit}><div><label htmlFor="headline" className="block text-sm font-medium text-gray-700 mb-1">Headline</label><input type="text" id="headline" value={headline} onChange={(e) => setHeadline(e.target.value)} className="block w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm" /></div><div><label htmlFor="content" className="block text-sm font-medium text-gray-700 mb-1">Full Article Content</label><textarea id="content" rows={10} value={content} onChange={(e) => setContent(e.target.value)} className="block w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm"></textarea></div><div><label htmlFor="video-upload" className="block text-sm font-medium text-gray-700 mb-1">Upload Supporting Video (Optional)</label><input id="video-upload" type="file" accept="video/*" onChange={handleFileChange} className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" />{videoFile && (<p className="mt-2 text-sm text-gray-600">Selected file: {videoFile.name}</p>)}</div><div><button type="submit" disabled={isConfirming} className="w-full flex justify-center py-3 px-4 border rounded-md shadow-sm font-medium text-white bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400">{isConfirming ? 'Waiting for confirmation...' : 'Submit Article'}</button></div></form>{isConfirmed && (<div className="mt-4 text-center text-green-600">Transaction confirmed! Redirecting...</div>)}</div></main></div>
  );
}