'use client';

import { useAccount } from 'wagmi';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { Trophy, FileText, CheckCircle, Vote, Coins, Loader2 } from 'lucide-react';
import { useUserRewardStats, useClaimStakingRewards } from '@/Hooks/useNewFeatures';
import { formatCRED } from '@/lib/contracts/newFeatures';
import { toast } from 'sonner';

export default function RewardsDashboard() {
  const { address } = useAccount();
  const { data: stats, isLoading } = useUserRewardStats(address);
  const { claimRewards, isPending } = useClaimStakingRewards();

  const handleClaimRewards = () => {
    claimRewards();
    toast.success('Staking rewards claimed!');
  };

  if (isLoading) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center h-48">
          <Loader2 className="h-8 w-8 animate-spin" />
        </CardContent>
      </Card>
    );
  }

  const totalEarned = stats?.[0] || 0n;
  const publishCount = stats?.[1] || 0n;
  const verifyCount = stats?.[2] || 0n;
  const govCount = stats?.[3] || 0n;
  const currentBalance = stats?.[4] || 0n;

  const rewardBreakdown = [
    {
      icon: FileText,
      label: 'Publishing',
      count: Number(publishCount),
      color: 'text-blue-500',
    },
    {
      icon: CheckCircle,
      label: 'Verification',
      count: Number(verifyCount),
      color: 'text-green-500',
    },
    {
      icon: Vote,
      label: 'Governance',
      count: Number(govCount),
      color: 'text-purple-500',
    },
  ];

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-2">
          <Trophy className="h-5 w-5 text-yellow-500" />
          <CardTitle>CRED Rewards</CardTitle>
        </div>
        <CardDescription>
          Track your reputation token earnings from platform contributions
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Total Earned */}
        <div className="text-center p-6 bg-gradient-to-br from-yellow-50 to-orange-50 dark:from-yellow-900/20 dark:to-orange-900/20 rounded-lg border border-yellow-200 dark:border-yellow-800">
          <div className="flex items-center justify-center gap-2 mb-2">
            <Coins className="h-6 w-6 text-yellow-600" />
            <p className="text-3xl font-bold text-yellow-700 dark:text-yellow-400">
              {formatCRED(totalEarned)}
            </p>
          </div>
          <p className="text-sm text-muted-foreground">Total CRED Earned</p>
        </div>

        {/* Current Balance */}
        <div className="flex items-center justify-between p-4 bg-muted rounded-lg">
          <span className="text-sm font-medium">Available Balance</span>
          <span className="text-lg font-bold">{formatCRED(currentBalance)} CRED</span>
        </div>

        {/* Activity Breakdown */}
        <div className="space-y-3">
          <p className="text-sm font-medium">Contribution Breakdown</p>
          {rewardBreakdown.map((item) => {
            const Icon = item.icon;
            const total = Number(publishCount) + Number(verifyCount) + Number(govCount);
            const percentage = total > 0 ? (item.count / total) * 100 : 0;

            return (
              <div key={item.label} className="space-y-2">
                <div className="flex items-center justify-between text-sm">
                  <div className="flex items-center gap-2">
                    <Icon className={`h-4 w-4 ${item.color}`} />
                    <span>{item.label}</span>
                  </div>
                  <span className="font-medium">{item.count}</span>
                </div>
                <Progress value={percentage} className="h-2" />
              </div>
            );
          })}
        </div>

        {/* Claim Staking Rewards */}
        <div className="p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
          <p className="text-sm text-blue-800 dark:text-blue-200 mb-3">
            Claim your daily staking rewards (0.001 CRED per NEWS staked)
          </p>
          <Button 
            onClick={handleClaimRewards} 
            disabled={isPending}
            className="w-full"
            variant="default"
          >
            {isPending ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Claiming...
              </>
            ) : (
              'Claim Staking Rewards'
            )}
          </Button>
        </div>

        {/* Info Box */}
        <div className="text-xs text-muted-foreground space-y-1 p-3 bg-muted/50 rounded-lg">
          <p>• Publishing quality news: 100-150 CRED</p>
          <p>• Accurate verification: 50-60 CRED</p>
          <p>• Governance participation: 25-29 CRED</p>
          <p>• Daily staking rewards: 0.001 CRED per NEWS</p>
        </div>
      </CardContent>
    </Card>
  );
}
