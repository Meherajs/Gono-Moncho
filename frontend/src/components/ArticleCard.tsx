import React from 'react';
import Link from 'next/link';

type ArticleCardProps = {
  id: number;
  headline: string;
  summary: string;
  author: string;
  status: 'Verified' | 'Pending';
  category: string; // Add category to props
  imageUrl?: string;
};

export default function ArticleCard({ id, headline, summary, category, imageUrl }: ArticleCardProps) {
  return (
    <Link href={`/article/${id}`} className="block group">
      <div className="flex flex-col h-full">
        {imageUrl && (
          <div className="mb-4 overflow-hidden">
            <img 
              src={imageUrl} 
              alt={headline} 
              className="w-full h-auto object-cover group-hover:scale-105 transition-transform duration-300 ease-in-out" 
            />
          </div>
        )}
        {/* Display the category tag */}
        <p className="text-sm font-semibold text-blue-600 mb-2">{category}</p>
        <h2 className="text-xl font-bold mb-2 text-gray-800 group-hover:text-blue-600">
          {headline}
        </h2>
        <p className="text-gray-600 text-sm flex-grow">
          {summary}
        </p>
      </div>
    </Link>
  );
}