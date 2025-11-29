'use client';

import { useState } from 'react';
import { useAccount } from 'wagmi';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Eye, EyeOff, Lock, Unlock, Loader2 } from 'lucide-react';
import { useCommitAnonymousPublish, useRevealContent, useGetCommitment } from '@/Hooks/useNewFeatures';
import { toast } from 'sonner';
import { keccak256, toBytes } from 'viem';

export default function AnonymousPublishCard() {
  const { address } = useAccount();
  const [step, setStep] = useState<'input' | 'committed' | 'revealed'>('input');
  const [content, setContent] = useState('');
  const [category, setCategory] = useState('Investigative');
  const [commitId, setCommitId] = useState<bigint>();
  const [secretSalt, setSecretSalt] = useState('');

  const { commitPublish, isPending: isCommitting } = useCommitAnonymousPublish();
  const { revealContent, isPending: isRevealing } = useRevealContent();
  const { data: commitment } = useGetCommitment(commitId);

  const handleCommit = async () => {
    if (!content || !address) {
      toast.error('Please enter content');
      return;
    }

    // Generate random salt for privacy
    const salt = Math.random().toString(36).substring(2);
    setSecretSalt(salt);

    // Create content hash
    const contentWithSalt = `${content}${salt}`;
    const contentHash = keccak256(toBytes(contentWithSalt));
    
    // Create commitment (hash of content + author)
    const commitmentValue = keccak256(
      toBytes(`${contentHash}${address}`)
    ) as `0x${string}`;

    commitPublish(commitmentValue, category);
    
    toast.success('Content committed! Save your salt: ' + salt);
    setStep('committed');
  };

  const handleReveal = async () => {
    if (!commitId || !address || !secretSalt) {
      toast.error('Missing commitment data');
      return;
    }

    const contentWithSalt = `${content}${secretSalt}`;
    const contentHash = keccak256(toBytes(contentWithSalt)) as `0x${string}`;

    revealContent(commitId, contentHash, address);
    
    toast.success('Content revealed!');
    setStep('revealed');
  };

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Lock className="h-5 w-5" />
            <CardTitle>Anonymous Publishing</CardTitle>
          </div>
          <Badge variant="outline">Zero-Knowledge Proof</Badge>
        </div>
        <CardDescription>
          Publish sensitive news anonymously using cryptographic commitments
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {step === 'input' && (
          <>
            <div className="space-y-2">
              <label className="text-sm font-medium">Category</label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="w-full px-3 py-2 border rounded-md"
              >
                <option value="Investigative">Investigative</option>
                <option value="Political">Political</option>
                <option value="Corporate">Corporate</option>
                <option value="Whistleblowing">Whistleblowing</option>
              </select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">News Content</label>
              <textarea
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder="Enter sensitive news content..."
                className="w-full px-3 py-2 border rounded-md min-h-[120px]"
              />
            </div>

            <div className="p-3 bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 rounded-lg">
              <p className="text-xs text-amber-800 dark:text-amber-200">
                <Eye className="inline h-3 w-3 mr-1" />
                Step 1: Commit your content hash on-chain (no content revealed)
              </p>
              <p className="text-xs text-amber-800 dark:text-amber-200 mt-1">
                <EyeOff className="inline h-3 w-3 mr-1" />
                Step 2: After 1 hour, reveal content with proof
              </p>
            </div>

            <Button 
              onClick={handleCommit} 
              disabled={isCommitting || !content}
              className="w-full"
            >
              {isCommitting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Committing...
                </>
              ) : (
                <>
                  <Lock className="mr-2 h-4 w-4" />
                  Commit Content Hash
                </>
              )}
            </Button>
          </>
        )}

        {step === 'committed' && (
          <>
            <div className="space-y-2">
              <div className="p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
                <p className="text-sm font-medium text-blue-800 dark:text-blue-200 mb-2">
                  ✓ Content Committed Successfully
                </p>
                <p className="text-xs text-blue-600 dark:text-blue-300 mb-2">
                  Commitment ID: {commitId?.toString() || 'Pending...'}
                </p>
                <p className="text-xs text-blue-600 dark:text-blue-300 font-mono break-all">
                  Salt (SAVE THIS): {secretSalt}
                </p>
              </div>

              {commitment && (
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Status:</span>
                    <Badge>{commitment[4] === 0 ? 'Committed' : 'Revealed'}</Badge>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Category:</span>
                    <span>{commitment[3]}</span>
                  </div>
                </div>
              )}
            </div>

            <Button 
              onClick={handleReveal} 
              disabled={isRevealing}
              className="w-full"
              variant="default"
            >
              {isRevealing ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Revealing...
                </>
              ) : (
                <>
                  <Unlock className="mr-2 h-4 w-4" />
                  Reveal Content (After 1 Hour)
                </>
              )}
            </Button>

            <Button 
              onClick={() => setStep('input')} 
              variant="outline"
              className="w-full"
            >
              New Commitment
            </Button>
          </>
        )}

        {step === 'revealed' && (
          <div className="space-y-3">
            <div className="p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg">
              <p className="text-sm font-medium text-green-800 dark:text-green-200 mb-2">
                ✓ Content Successfully Revealed
              </p>
              <p className="text-xs text-green-600 dark:text-green-300">
                Your anonymous publication is now live on-chain with cryptographic proof of commitment.
              </p>
            </div>

            <Button 
              onClick={() => {
                setStep('input');
                setContent('');
                setCommitId(undefined);
                setSecretSalt('');
              }} 
              className="w-full"
            >
              Publish Another Story
            </Button>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
