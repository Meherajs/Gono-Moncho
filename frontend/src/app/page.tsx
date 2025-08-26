"use client";

import ArticleCard from "@/components/ArticleCard";
import { useArticles } from "@/context/ArticleContext";

export default function HomePage() {
  // --- NEW: Use filteredArticles from the context ---
  const { filteredArticles } = useArticles();

  // Separate articles for different parts of the grid
  const mainStory = filteredArticles[0];
  const topStories = filteredArticles.slice(1, 3);
  const secondaryStories = filteredArticles.slice(3, 6);

  return (
    <div className="bg-white min-h-screen">
      <main className="container mx-auto p-4 sm:p-6 lg:p-8">
        {/* ... The rest of the grid layout is unchanged ... */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8 pb-8 border-b">
          <div className="lg:col-span-2">{mainStory && <ArticleCard {...mainStory} />}</div>
          <div className="lg:col-span-1 flex flex-col gap-8">{topStories.map((article) => (<ArticleCard key={article.id} {...article} />))}</div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {secondaryStories.map((article) => (
            <div key={article.id}><ArticleCard {...article} /></div>
          ))}
        </div>
      </main>
    </div>
  );
}