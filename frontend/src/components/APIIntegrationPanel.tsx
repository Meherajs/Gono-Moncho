"use client";

import { useState } from 'react';
import { useAccount, useReadContract, useWriteContract } from 'wagmi';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { 
  DECENTRALIZED_PUBLISHING_API_ABI, 
  DECENTRALIZED_PUBLISHING_API_ADDRESS 
} from '@/lib/contracts/organizationFeatures';

export default function APIIntegrationPanel() {
  const { address } = useAccount();
  const [articleData, setArticleData] = useState({
    authorAddress: '',
    title: '',
    contentHash: '',
    category: 'POLITICS'
  });

  // Read API key and rate limit data
  const { data: apiKeyData } = useReadContract({
    address: DECENTRALIZED_PUBLISHING_API_ADDRESS,
    abi: DECENTRALIZED_PUBLISHING_API_ABI,
    functionName: 'outletAPIKeys',
    args: [address as `0x${string}`],
  });

  const { data: rateLimitStatus } = useReadContract({
    address: DECENTRALIZED_PUBLISHING_API_ADDRESS,
    abi: DECENTRALIZED_PUBLISHING_API_ABI,
    functionName: 'getRateLimitStatus',
    args: [address as `0x${string}`],
  });

  const { writeContract: generateKey, isPending: isGenerating } = useWriteContract();
  const { writeContract: submitArticle, isPending: isSubmitting } = useWriteContract();

  const handleGenerateKey = () => {
    generateKey({
      address: DECENTRALIZED_PUBLISHING_API_ADDRESS,
      abi: DECENTRALIZED_PUBLISHING_API_ABI,
      functionName: 'generateAPIKey',
      args: [address as `0x${string}`]
    });
  };

  const handleSubmitArticle = () => {
    if (!apiKeyData || !apiKeyData[0]) {
      alert('Please generate an API key first');
      return;
    }

    submitArticle({
      address: DECENTRALIZED_PUBLISHING_API_ADDRESS,
      abi: DECENTRALIZED_PUBLISHING_API_ABI,
      functionName: 'submitArticle',
      args: [
        apiKeyData[0],
        articleData.authorAddress as `0x${string}`,
        articleData.title,
        articleData.contentHash,
        articleData.category
      ]
    });
  };

  const categories = [
    'POLITICS', 'SPORTS', 'TECHNOLOGY', 'BUSINESS', 
    'ENTERTAINMENT', 'SCIENCE', 'HEALTH', 'WORLD', 'LOCAL'
  ];

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>API Integration</CardTitle>
          <CardDescription>
            Integrate Gono Moncho publishing into your existing CMS
          </CardDescription>
        </CardHeader>
        <CardContent>
          {!apiKeyData || !apiKeyData[0] ? (
            <div className="space-y-4">
              <Alert>
                <AlertDescription>
                  No API key found. Generate one to start publishing.
                </AlertDescription>
              </Alert>
              <Button onClick={handleGenerateKey} disabled={isGenerating}>
                {isGenerating ? 'Generating...' : 'Generate API Key'}
              </Button>
            </div>
          ) : (
            <div className="space-y-4">
              <div className="p-4 bg-gray-100 rounded-lg">
                <Label>Your API Key</Label>
                <div className="flex items-center gap-2 mt-2">
                  <code className="flex-1 p-2 bg-white rounded border font-mono text-sm">
                    {apiKeyData[0]}
                  </code>
                  <Button 
                    size="sm" 
                    variant="outline"
                    onClick={() => navigator.clipboard.writeText(apiKeyData[0] as string)}
                  >
                    Copy
                  </Button>
                </div>
              </div>

              {rateLimitStatus && (
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-gray-500">Articles Submitted Today</p>
                    <p className="text-2xl font-bold">{Number(rateLimitStatus[0])}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Daily Limit</p>
                    <p className="text-2xl font-bold">{Number(rateLimitStatus[1])}</p>
                  </div>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </Card>

      <Tabs defaultValue="submit" className="w-full">
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="submit">Submit Article</TabsTrigger>
          <TabsTrigger value="docs">Documentation</TabsTrigger>
        </TabsList>

        <TabsContent value="submit">
          <Card>
            <CardHeader>
              <CardTitle>Submit Article via API</CardTitle>
              <CardDescription>Test the API integration</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="author">Author Address</Label>
                <Input
                  id="author"
                  placeholder="0x..."
                  value={articleData.authorAddress}
                  onChange={(e) => setArticleData({ ...articleData, authorAddress: e.target.value })}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="title">Article Title</Label>
                <Input
                  id="title"
                  placeholder="Breaking News..."
                  value={articleData.title}
                  onChange={(e) => setArticleData({ ...articleData, title: e.target.value })}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="contentHash">Content Hash (Arweave)</Label>
                <Input
                  id="contentHash"
                  placeholder="https://arweave.net/..."
                  value={articleData.contentHash}
                  onChange={(e) => setArticleData({ ...articleData, contentHash: e.target.value })}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="category">Category</Label>
                <select
                  id="category"
                  className="w-full p-2 border rounded"
                  value={articleData.category}
                  onChange={(e) => setArticleData({ ...articleData, category: e.target.value })}
                >
                  {categories.map(cat => (
                    <option key={cat} value={cat}>{cat}</option>
                  ))}
                </select>
              </div>

              <Button 
                onClick={handleSubmitArticle} 
                disabled={isSubmitting || !apiKeyData}
                className="w-full"
              >
                {isSubmitting ? 'Submitting...' : 'Submit Article'}
              </Button>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="docs">
          <Card>
            <CardHeader>
              <CardTitle>API Documentation</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <h3 className="font-semibold mb-2">REST Endpoint</h3>
                <code className="block p-4 bg-gray-100 rounded">
                  POST https://api.gonomoncho.com/v1/articles
                </code>
              </div>

              <div>
                <h3 className="font-semibold mb-2">Headers</h3>
                <pre className="p-4 bg-gray-100 rounded text-sm">
{`Authorization: Bearer YOUR_API_KEY
Content-Type: application/json`}
                </pre>
              </div>

              <div>
                <h3 className="font-semibold mb-2">Request Body</h3>
                <pre className="p-4 bg-gray-100 rounded text-sm overflow-x-auto">
{`{
  "authorAddress": "0x...",
  "title": "Article Title",
  "contentHash": "arweave_hash",
  "category": "POLITICS"
}`}
                </pre>
              </div>

              <div>
                <h3 className="font-semibold mb-2">Rate Limits</h3>
                <ul className="list-disc list-inside space-y-1 text-sm">
                  <li>Standard: 100 articles/day</li>
                  <li>Premium: 1000 articles/day</li>
                  <li>Verified outlets: Auto-approval enabled</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold mb-2">Batch Submission</h3>
                <code className="block p-4 bg-gray-100 rounded text-sm">
                  POST https://api.gonomoncho.com/v1/articles/batch
                </code>
                <p className="text-sm text-gray-600 mt-2">
                  Submit up to 50 articles in a single request
                </p>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
