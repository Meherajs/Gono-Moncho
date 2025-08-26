"use client";

import React from 'react';
import Link from 'next/link';
import ConnectButton from './ConnectButton';
import { useArticles } from '@/context/ArticleContext';
import { useAccount } from 'wagmi'; // The only hook we now need for this logic

export default function Header() {
  const { categories, selectedCategory, setSelectedCategory } = useArticles();
  const { isConnected } = useAccount(); // Get the connection status directly

  return (
    <header className="bg-white text-black border-b shadow-sm">
      {/* Top bar */}
      <div className="container mx-auto px-4 py-2 flex justify-between items-center text-sm">
        <span className="text-gray-500">{new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</span>
        <div className="flex items-center gap-4">
          
          {/* The Publish button is now ONLY dependent on being connected */}
          {isConnected && (
            <Link href="/publish" className="font-semibold text-white bg-blue-600 hover:bg-blue-700 px-3 py-1 rounded-md transition-colors duration-200">
              Publish Article
            </Link>
          )}

          <ConnectButton />
        </div>
      </div>
      
      {/* Main header with logo */}
      <div className="py-6 text-center border-t">
        <Link href="/" className="text-5xl font-serif font-bold text-gray-800">Gono Moncho</Link>
        <p className="text-sm text-gray-500 mt-2">A Decentralized Ecosystem for Verifiable Journalism</p>
      </div>

      {/* Category Navigation Bar */}
      <nav className="border-t border-b bg-gray-50 sticky top-0 z-10">
        <div className="container mx-auto px-4 flex justify-center items-center gap-x-6 sm:gap-x-8 text-sm font-semibold">
          {categories.map((category) => (
            <button 
              key={category} 
              onClick={() => setSelectedCategory(category)}
              className={`py-3 hover:text-black border-b-2 transition-colors duration-200 ${
                selectedCategory === category
                  ? 'border-black text-black'
                  : 'border-transparent text-gray-600'
              }`}
            >
              {category}
            </button>
          ))}
        </div>
      </nav>
    </header>
  );
}