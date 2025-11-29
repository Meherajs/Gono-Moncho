'use client';

import { useAccount } from 'wagmi';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Scale, TrendingUp, Users, Loader2 } from 'lucide-react';
import { useVotingPowerBreakdown } from '@/Hooks/useNewFeatures';
import { CONTRACT_ADDRESSES } from '@/lib/contracts/newFeatures';
import { formatCRED } from '@/lib/contracts/newFeatures';

interface VotingPowerCardProps {
  stakingContract?: `0x${string}`;
  credToken?: `0x${string}`;
}

export default function VotingPowerCard({ 
  stakingContract, 
  credToken 
}: VotingPowerCardProps) {
  const { address } = useAccount();
  
  const { data: breakdown, isLoading } = useVotingPowerBreakdown(
    address,
    stakingContract,
    credToken
  );

  if (isLoading) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center h-48">
          <Loader2 className="h-8 w-8 animate-spin" />
        </CardContent>
      </Card>
    );
  }

  const totalPower = breakdown?.[0] || 0n;
  const fromStake = breakdown?.[1] || 0n;
  const fromReputation = breakdown?.[2] || 0n;

  const stakePercentage = totalPower > 0n 
    ? Number((fromStake * 100n) / totalPower) 
    : 0;
  const reputationPercentage = totalPower > 0n 
    ? Number((fromReputation * 100n) / totalPower) 
    : 0;

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-2">
          <Scale className="h-5 w-5 text-purple-500" />
          <CardTitle>Voting Power</CardTitle>
        </div>
        <CardDescription>
          Hybrid governance: 50% economic stake + 50% reputation
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Total Voting Power */}
        <div className="text-center p-6 bg-gradient-to-br from-purple-50 to-indigo-50 dark:from-purple-900/20 dark:to-indigo-900/20 rounded-lg border border-purple-200 dark:border-purple-800">
          <div className="flex items-center justify-center gap-2 mb-2">
            <TrendingUp className="h-6 w-6 text-purple-600" />
            <p className="text-3xl font-bold text-purple-700 dark:text-purple-400">
              {formatCRED(totalPower)}
            </p>
          </div>
          <p className="text-sm text-muted-foreground">Total Voting Power</p>
        </div>

        {/* Breakdown */}
        <div className="space-y-4">
          <h3 className="text-sm font-semibold">Power Breakdown</h3>

          {/* Economic Stake */}
          <div className="space-y-2">
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center gap-2">
                <Users className="h-4 w-4 text-blue-500" />
                <span>Economic Stake (NEWS)</span>
              </div>
              <span className="font-medium">{stakePercentage}%</span>
            </div>
            <div className="w-full bg-muted rounded-full h-2.5">
              <div 
                className="bg-blue-500 h-2.5 rounded-full transition-all"
                style={{ width: `${stakePercentage}%` }}
              />
            </div>
            <p className="text-xs text-muted-foreground">
              {formatCRED(fromStake)} voting power from staked NEWS
            </p>
          </div>

          {/* Reputation */}
          <div className="space-y-2">
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center gap-2">
                <TrendingUp className="h-4 w-4 text-yellow-500" />
                <span>Reputation (CRED)</span>
              </div>
              <span className="font-medium">{reputationPercentage}%</span>
            </div>
            <div className="w-full bg-muted rounded-full h-2.5">
              <div 
                className="bg-yellow-500 h-2.5 rounded-full transition-all"
                style={{ width: `${reputationPercentage}%` }}
              />
            </div>
            <p className="text-xs text-muted-foreground">
              {formatCRED(fromReputation)} voting power from CRED reputation
            </p>
          </div>
        </div>

        {/* Distribution Visual */}
        <div className="flex h-3 rounded-full overflow-hidden">
          <div 
            className="bg-blue-500" 
            style={{ width: `${stakePercentage}%` }}
            title="Economic Stake"
          />
          <div 
            className="bg-yellow-500" 
            style={{ width: `${reputationPercentage}%` }}
            title="Reputation"
          />
        </div>

        {/* Info */}
        <div className="p-3 bg-indigo-50 dark:bg-indigo-900/20 border border-indigo-200 dark:border-indigo-800 rounded-lg">
          <p className="text-xs text-indigo-800 dark:text-indigo-200">
            <strong>Balanced Governance:</strong> Your voting power combines economic commitment (staked NEWS) with earned reputation (CRED tokens) to prevent plutocracy while rewarding contributors.
          </p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-2 gap-3">
          <div className="p-3 bg-muted rounded-lg">
            <p className="text-xs text-muted-foreground mb-1">Weight Split</p>
            <p className="text-sm font-bold">50/50</p>
          </div>
          <div className="p-3 bg-muted rounded-lg">
            <p className="text-xs text-muted-foreground mb-1">Model</p>
            <p className="text-sm font-bold">Hybrid</p>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
