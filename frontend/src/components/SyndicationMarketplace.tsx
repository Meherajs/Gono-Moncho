"use client";

import { useState } from 'react';
import { useAccount, useReadContract, useWriteContract } from 'wagmi';
import { formatEther, parseEther } from 'viem';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { 
  SYNDICATION_LICENSING_ABI, 
  SYNDICATION_LICENSING_ADDRESS 
} from '@/lib/contracts/organizationFeatures';

export default function SyndicationMarketplace() {
  const { address } = useAccount();
  const [contentId, setContentId] = useState('');
  const [isExclusive, setIsExclusive] = useState(false);
  const [licenseeData, setLicenseeData] = useState({
    name: '',
    subscriberCount: ''
  });

  // Read licensee data
  const { data: licenseeInfo } = useReadContract({
    address: SYNDICATION_LICENSING_ADDRESS,
    abi: SYNDICATION_LICENSING_ABI,
    functionName: 'licensees',
    args: [address as `0x${string}`],
  });

  // Read journalist revenue
  const { data: journalistRevenue } = useReadContract({
    address: SYNDICATION_LICENSING_ADDRESS,
    abi: SYNDICATION_LICENSING_ABI,
    functionName: 'journalistRevenue',
    args: [address as `0x${string}`],
  });

  const { writeContract: registerLicensee, isPending: isRegistering } = useWriteContract();
  const { writeContract: purchaseLicense, isPending: isPurchasing } = useWriteContract();
  const { writeContract: withdrawRevenue, isPending: isWithdrawing } = useWriteContract();

  const handleRegisterLicensee = () => {
    registerLicensee({
      address: SYNDICATION_LICENSING_ADDRESS,
      abi: SYNDICATION_LICENSING_ABI,
      functionName: 'registerLicensee',
      args: [licenseeData.name, BigInt(licenseeData.subscriberCount)]
    });
  };

  const handlePurchaseLicense = () => {
    const tier = licenseeInfo ? licenseeInfo[2] : 0;
    const prices = [parseEther('0.001'), parseEther('0.01'), parseEther('0.05'), parseEther('0.1')];
    const price = prices[tier as number];
    const finalPrice = isExclusive ? price * BigInt(3) : price;

    purchaseLicense({
      address: SYNDICATION_LICENSING_ADDRESS,
      abi: SYNDICATION_LICENSING_ABI,
      functionName: 'purchaseLicense',
      args: [contentId, isExclusive],
      value: finalPrice
    });
  };

  const handleWithdrawRevenue = () => {
    withdrawRevenue({
      address: SYNDICATION_LICENSING_ADDRESS,
      abi: SYNDICATION_LICENSING_ABI,
      functionName: 'withdrawJournalistRevenue',
      args: []
    });
  };

  const getTierBadge = (tier: number) => {
    const tiers = ['Small', 'Medium', 'Large', 'Enterprise'];
    const colors = ['bg-gray-500', 'bg-blue-500', 'bg-purple-500', 'bg-yellow-500'];
    return <Badge className={colors[tier]}>{tiers[tier]}</Badge>;
  };

  const getTierPrice = (tier: number, exclusive: boolean) => {
    const prices = ['0.001', '0.01', '0.05', '0.1'];
    const price = prices[tier];
    return exclusive ? (parseFloat(price) * 3).toString() : price;
  };

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Syndication Marketplace</CardTitle>
          <CardDescription>
            License content for republishing or earn from syndication
          </CardDescription>
        </CardHeader>
        <CardContent>
          {journalistRevenue && BigInt(journalistRevenue as bigint) > 0 && (
            <div className="mb-4 p-4 bg-green-50 border border-green-200 rounded-lg">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600">Available Revenue</p>
                  <p className="text-2xl font-bold text-green-600">
                    {formatEther(journalistRevenue as bigint)} ETH
                  </p>
                </div>
                <Button onClick={handleWithdrawRevenue} disabled={isWithdrawing}>
                  {isWithdrawing ? 'Processing...' : 'Withdraw'}
                </Button>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      <Tabs defaultValue="purchase" className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="purchase">Purchase License</TabsTrigger>
          <TabsTrigger value="register">Register as Licensee</TabsTrigger>
          <TabsTrigger value="pricing">Pricing Info</TabsTrigger>
        </TabsList>

        <TabsContent value="purchase">
          <Card>
            <CardHeader>
              <CardTitle>Purchase Content License</CardTitle>
              <CardDescription>
                Buy republishing rights for news content
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              {!licenseeInfo || !licenseeInfo[0] ? (
                <div className="p-4 bg-yellow-50 border border-yellow-200 rounded">
                  <p className="text-sm">You must register as a licensee first to purchase content.</p>
                </div>
              ) : (
                <>
                  <div className="p-4 bg-gray-50 rounded-lg space-y-2">
                    <div className="flex justify-between">
                      <span className="text-sm text-gray-600">Licensee Name</span>
                      <span className="font-semibold">{licenseeInfo[0]}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-sm text-gray-600">Subscriber Count</span>
                      <span className="font-semibold">{Number(licenseeInfo[1]).toLocaleString()}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-sm text-gray-600">Tier</span>
                      {getTierBadge(licenseeInfo[2] as number)}
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="contentId">Content ID</Label>
                    <Input
                      id="contentId"
                      placeholder="article_hash_123"
                      value={contentId}
                      onChange={(e) => setContentId(e.target.value)}
                    />
                  </div>

                  <div className="flex items-center space-x-2">
                    <input
                      type="checkbox"
                      id="exclusive"
                      checked={isExclusive}
                      onChange={(e) => setIsExclusive(e.target.checked)}
                      className="w-4 h-4"
                    />
                    <Label htmlFor="exclusive">
                      Exclusive License (3x price, 30 days exclusivity)
                    </Label>
                  </div>

                  {licenseeInfo && (
                    <div className="p-4 bg-blue-50 rounded-lg">
                      <p className="text-sm text-gray-600 mb-1">License Price</p>
                      <p className="text-2xl font-bold text-blue-600">
                        {getTierPrice(licenseeInfo[2] as number, isExclusive)} ETH
                      </p>
                      <p className="text-xs text-gray-500 mt-2">
                        Revenue split: 60% journalist, 30% outlet, 10% platform
                      </p>
                    </div>
                  )}

                  <Button 
                    onClick={handlePurchaseLicense} 
                    disabled={isPurchasing || !contentId}
                    className="w-full"
                  >
                    {isPurchasing ? 'Processing...' : 'Purchase License'}
                  </Button>
                </>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="register">
          <Card>
            <CardHeader>
              <CardTitle>Register as Licensee</CardTitle>
              <CardDescription>
                Register your organization to purchase syndication licenses
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="licenseeName">Organization Name</Label>
                <Input
                  id="licenseeName"
                  placeholder="Regional News Network"
                  value={licenseeData.name}
                  onChange={(e) => setLicenseeData({ ...licenseeData, name: e.target.value })}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="subscribers">Total Subscriber Count</Label>
                <Input
                  id="subscribers"
                  type="number"
                  placeholder="50000"
                  value={licenseeData.subscriberCount}
                  onChange={(e) => setLicenseeData({ ...licenseeData, subscriberCount: e.target.value })}
                />
                <p className="text-xs text-gray-500">
                  This determines your pricing tier
                </p>
              </div>

              <Button 
                onClick={handleRegisterLicensee} 
                disabled={isRegistering}
                className="w-full"
              >
                {isRegistering ? 'Registering...' : 'Register'}
              </Button>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="pricing">
          <Card>
            <CardHeader>
              <CardTitle>Pricing Tiers</CardTitle>
              <CardDescription>License pricing based on subscriber count</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="border rounded-lg p-4">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-semibold">Small Tier</h3>
                    <Badge className="bg-gray-500">{'<'}10,000 subscribers</Badge>
                  </div>
                  <p className="text-2xl font-bold">0.001 ETH</p>
                  <p className="text-sm text-gray-500">per article</p>
                </div>

                <div className="border rounded-lg p-4">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-semibold">Medium Tier</h3>
                    <Badge className="bg-blue-500">10,000 - 100,000</Badge>
                  </div>
                  <p className="text-2xl font-bold">0.01 ETH</p>
                  <p className="text-sm text-gray-500">per article</p>
                </div>

                <div className="border rounded-lg p-4">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-semibold">Large Tier</h3>
                    <Badge className="bg-purple-500">100,000 - 1,000,000</Badge>
                  </div>
                  <p className="text-2xl font-bold">0.05 ETH</p>
                  <p className="text-sm text-gray-500">per article</p>
                </div>

                <div className="border rounded-lg p-4">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-semibold">Enterprise Tier</h3>
                    <Badge className="bg-yellow-500">{'>'}1,000,000</Badge>
                  </div>
                  <p className="text-2xl font-bold">0.1 ETH</p>
                  <p className="text-sm text-gray-500">per article</p>
                </div>

                <div className="mt-6 p-4 bg-gray-50 rounded-lg">
                  <h4 className="font-semibold mb-2">Revenue Distribution</h4>
                  <ul className="space-y-1 text-sm">
                    <li>• <strong>60%</strong> to journalist/author</li>
                    <li>• <strong>30%</strong> to original outlet</li>
                    <li>• <strong>10%</strong> to platform</li>
                  </ul>
                </div>

                <div className="mt-4 p-4 bg-blue-50 rounded-lg">
                  <h4 className="font-semibold mb-2">License Duration</h4>
                  <p className="text-sm">All licenses are valid for <strong>365 days</strong> from purchase</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
