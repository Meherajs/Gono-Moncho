"use client";

import { useState } from 'react';
import { useAccount, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther } from 'viem';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { NEWS_OUTLET_REGISTRY_ABI, NEWS_OUTLET_REGISTRY_ADDRESS } from '@/lib/contracts/organizationFeatures';

export default function NewsOutletRegistrationCard() {
  const { address } = useAccount();
  const [formData, setFormData] = useState({
    name: '',
    legalEntity: '',
    registrationNumber: '',
    jurisdiction: '',
    website: '',
    treasuryAddress: '',
    stakeAmount: '10000'
  });

  const { writeContract, data: hash, isPending, error } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const handleRegister = async () => {
    if (!formData.name || !formData.legalEntity || !formData.treasuryAddress) {
      alert('Please fill in all required fields');
      return;
    }

    writeContract({
      address: NEWS_OUTLET_REGISTRY_ADDRESS,
      abi: NEWS_OUTLET_REGISTRY_ABI,
      functionName: 'registerOutlet',
      args: [
        formData.name,
        formData.legalEntity,
        formData.registrationNumber,
        formData.jurisdiction,
        formData.website,
        formData.treasuryAddress as `0x${string}`
      ],
      value: parseEther(formData.stakeAmount)
    });
  };

  return (
    <Card className="w-full max-w-2xl">
      <CardHeader>
        <CardTitle>Register News Outlet</CardTitle>
        <CardDescription>
          Register your news organization to integrate with Gono Moncho. Requires a minimum stake of 10,000 NEWS tokens.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="space-y-2">
          <Label htmlFor="name">Outlet Name *</Label>
          <Input
            id="name"
            placeholder="The Daily News"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
          />
        </div>

        <div className="space-y-2">
          <Label htmlFor="legalEntity">Legal Entity Name *</Label>
          <Input
            id="legalEntity"
            placeholder="Daily News Corp Ltd"
            value={formData.legalEntity}
            onChange={(e) => setFormData({ ...formData, legalEntity: e.target.value })}
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label htmlFor="regNumber">Registration Number</Label>
            <Input
              id="regNumber"
              placeholder="REG123456"
              value={formData.registrationNumber}
              onChange={(e) => setFormData({ ...formData, registrationNumber: e.target.value })}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="jurisdiction">Jurisdiction</Label>
            <Input
              id="jurisdiction"
              placeholder="United States"
              value={formData.jurisdiction}
              onChange={(e) => setFormData({ ...formData, jurisdiction: e.target.value })}
            />
          </div>
        </div>

        <div className="space-y-2">
          <Label htmlFor="website">Website</Label>
          <Input
            id="website"
            type="url"
            placeholder="https://dailynews.com"
            value={formData.website}
            onChange={(e) => setFormData({ ...formData, website: e.target.value })}
          />
        </div>

        <div className="space-y-2">
          <Label htmlFor="treasury">Treasury Address *</Label>
          <Input
            id="treasury"
            placeholder="0x..."
            value={formData.treasuryAddress}
            onChange={(e) => setFormData({ ...formData, treasuryAddress: e.target.value })}
          />
        </div>

        <div className="space-y-2">
          <Label htmlFor="stake">Stake Amount (NEWS tokens)</Label>
          <Input
            id="stake"
            type="number"
            min="10000"
            value={formData.stakeAmount}
            onChange={(e) => setFormData({ ...formData, stakeAmount: e.target.value })}
          />
          <p className="text-sm text-gray-500">Minimum: 10,000 NEWS</p>
        </div>

        <Button
          onClick={handleRegister}
          disabled={!address || isPending || isConfirming}
          className="w-full"
        >
          {isPending ? 'Confirming...' : isConfirming ? 'Processing...' : 'Register Outlet'}
        </Button>

        {error && (
          <Alert variant="destructive">
            <AlertDescription>
              Error: {error.message}
            </AlertDescription>
          </Alert>
        )}

        {isSuccess && (
          <Alert>
            <AlertDescription>
              Registration successful! Your outlet is pending verification by the DAO.
            </AlertDescription>
          </Alert>
        )}
      </CardContent>
    </Card>
  );
}
