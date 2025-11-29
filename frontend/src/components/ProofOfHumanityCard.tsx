'use client';

import { useState } from 'react';
import { useAccount } from 'wagmi';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Shield, Users, CheckCircle, XCircle, Loader2 } from 'lucide-react';
import { useIsVerifiedHuman, useSocialMetrics, useSubmitProof } from '@/Hooks/useNewFeatures';
import { toast } from 'sonner';

export default function ProofOfHumanityCard() {
  const { address } = useAccount();
  const [connections, setConnections] = useState<string[]>([]);
  const [connectionInput, setConnectionInput] = useState('');
  
  const { data: isVerified, isLoading: verificationLoading } = useIsVerifiedHuman(address);
  const { data: metrics, isLoading: metricsLoading } = useSocialMetrics(address);
  const { submitProof, isPending } = useSubmitProof();

  const handleAddConnection = () => {
    if (connectionInput && connectionInput.startsWith('0x')) {
      setConnections([...connections, connectionInput]);
      setConnectionInput('');
    } else {
      toast.error('Invalid address format');
    }
  };

  const handleSubmitProof = async () => {
    if (connections.length < 2) {
      toast.error('Add at least 2 social connections');
      return;
    }

    const contextHash = `0x${Buffer.from(JSON.stringify({ 
      timestamp: Date.now(),
      connections 
    })).toString('hex').padEnd(64, '0')}` as `0x${string}`;
    
    const confidenceScore = Math.min(75 + connections.length * 5, 100);

    submitProof(
      contextHash,
      confidenceScore,
      connections as `0x${string}`[]
    );

    toast.success('Proof submitted for verification');
  };

  if (verificationLoading || metricsLoading) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center h-48">
          <Loader2 className="h-8 w-8 animate-spin" />
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Shield className="h-5 w-5" />
            <CardTitle>Proof of Humanity</CardTitle>
          </div>
          {isVerified ? (
            <Badge variant="default" className="gap-1">
              <CheckCircle className="h-3 w-3" />
              Verified Human
            </Badge>
          ) : (
            <Badge variant="secondary" className="gap-1">
              <XCircle className="h-3 w-3" />
              Not Verified
            </Badge>
          )}
        </div>
        <CardDescription>
          Privacy-preserving Sybil resistance through social connections
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {metrics && (
          <div className="grid grid-cols-2 gap-4">
            <div className="flex items-center gap-2 p-3 bg-muted rounded-lg">
              <Users className="h-4 w-4 text-muted-foreground" />
              <div>
                <p className="text-sm font-medium">{metrics[0]?.toString() || '0'}</p>
                <p className="text-xs text-muted-foreground">Connections</p>
              </div>
            </div>
            <div className="flex items-center gap-2 p-3 bg-muted rounded-lg">
              <Shield className="h-4 w-4 text-muted-foreground" />
              <div>
                <p className="text-sm font-medium">{metrics[1]?.toString() || '0'}%</p>
                <p className="text-xs text-muted-foreground">Confidence</p>
              </div>
            </div>
          </div>
        )}

        {!isVerified && (
          <div className="space-y-3">
            <div className="space-y-2">
              <label className="text-sm font-medium">Add Social Connection</label>
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="0x..."
                  value={connectionInput}
                  onChange={(e) => setConnectionInput(e.target.value)}
                  className="flex-1 px-3 py-2 border rounded-md text-sm"
                />
                <Button onClick={handleAddConnection} variant="outline" size="sm">
                  Add
                </Button>
              </div>
            </div>

            {connections.length > 0 && (
              <div className="space-y-2">
                <p className="text-sm font-medium">Connected Accounts ({connections.length})</p>
                <div className="flex flex-wrap gap-2">
                  {connections.map((conn, idx) => (
                    <Badge key={idx} variant="secondary">
                      {conn.slice(0, 6)}...{conn.slice(-4)}
                    </Badge>
                  ))}
                </div>
              </div>
            )}

            <Button 
              onClick={handleSubmitProof} 
              disabled={isPending || connections.length < 2}
              className="w-full"
            >
              {isPending ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Submitting...
                </>
              ) : (
                'Submit Verification Proof'
              )}
            </Button>
          </div>
        )}

        {isVerified && (
          <div className="p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg">
            <p className="text-sm text-green-800 dark:text-green-200">
              ✓ You are verified as a unique human. You can now publish news anonymously and participate in governance.
            </p>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
