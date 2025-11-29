'use client';

import { useState } from 'react';
import { useAccount } from 'wagmi';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Scale, FileCheck, MessageSquare, Loader2 } from 'lucide-react';
import { useRequestReview, useGetReview, useCastVote } from '@/Hooks/useNewFeatures';
import { toast } from 'sonner';
import { keccak256, toBytes } from 'viem';

export default function CouncilReviewCard() {
  const { address } = useAccount();
  const [contentId, setContentId] = useState('');
  const [specialty, setSpecialty] = useState('Investigative');
  const [reason, setReason] = useState('');
  const [reviewId, setReviewId] = useState<bigint>();
  const [vote, setVote] = useState<boolean | null>(null);
  const [feedback, setFeedback] = useState('');

  const { requestReview, isPending: isRequesting } = useRequestReview();
  const { data: review } = useGetReview(reviewId);
  const { castVote: submitVote, isPending: isVoting } = useCastVote();

  const handleRequestReview = () => {
    if (!contentId || !reason) {
      toast.error('Please fill in all fields');
      return;
    }

    const contentHash = keccak256(toBytes(contentId)) as `0x${string}`;
    requestReview(contentHash, specialty, reason);
    
    toast.success('Review requested from Journalistic Integrity Council');
  };

  const handleCastVote = () => {
    if (!reviewId || vote === null || !feedback) {
      toast.error('Please provide vote and feedback');
      return;
    }

    submitVote(reviewId, vote, feedback);
    toast.success('Vote submitted successfully');
  };

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-2">
          <Scale className="h-5 w-5 text-indigo-500" />
          <CardTitle>Journalistic Integrity Council</CardTitle>
        </div>
        <CardDescription>
          Request expert review for high-impact or contentious news stories
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Request Review Section */}
        <div className="space-y-4">
          <h3 className="text-sm font-semibold flex items-center gap-2">
            <FileCheck className="h-4 w-4" />
            Request Expert Review
          </h3>

          <div className="space-y-3">
            <div className="space-y-2">
              <label className="text-sm font-medium">Content ID</label>
              <input
                type="text"
                value={contentId}
                onChange={(e) => setContentId(e.target.value)}
                placeholder="Enter content hash or ID"
                className="w-full px-3 py-2 border rounded-md text-sm"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Specialty Required</label>
              <select
                value={specialty}
                onChange={(e) => setSpecialty(e.target.value)}
                className="w-full px-3 py-2 border rounded-md text-sm"
              >
                <option value="Investigative">Investigative Journalism</option>
                <option value="Political">Political Analysis</option>
                <option value="Science">Science & Technology</option>
                <option value="Legal">Legal & Compliance</option>
                <option value="Economics">Economics & Finance</option>
              </select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Review Reason</label>
              <textarea
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                placeholder="Explain why expert review is needed..."
                className="w-full px-3 py-2 border rounded-md text-sm min-h-[80px]"
              />
            </div>

            <Button 
              onClick={handleRequestReview} 
              disabled={isRequesting}
              className="w-full"
            >
              {isRequesting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Requesting...
                </>
              ) : (
                'Request Council Review'
              )}
            </Button>
          </div>
        </div>

        {/* View Review Section */}
        {review && (
          <div className="space-y-4 pt-4 border-t">
            <h3 className="text-sm font-semibold">Review Details</h3>

            <div className="space-y-3">
              <div className="flex items-center justify-between p-3 bg-muted rounded-lg">
                <div>
                  <p className="text-sm font-medium">Status</p>
                  <p className="text-xs text-muted-foreground">
                    {review[6] ? 'Finalized' : 'In Progress'}
                  </p>
                </div>
                <Badge variant={review[7] ? 'default' : 'destructive'}>
                  {review[7] ? 'Approved' : review[6] ? 'Rejected' : 'Pending'}
                </Badge>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="p-3 bg-green-50 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-800">
                  <p className="text-2xl font-bold text-green-700 dark:text-green-400">
                    {review[3]}
                  </p>
                  <p className="text-xs text-green-600 dark:text-green-300">Votes For</p>
                </div>
                <div className="p-3 bg-red-50 dark:bg-red-900/20 rounded-lg border border-red-200 dark:border-red-800">
                  <p className="text-2xl font-bold text-red-700 dark:text-red-400">
                    {review[4]}
                  </p>
                  <p className="text-xs text-red-600 dark:text-red-300">Votes Against</p>
                </div>
              </div>

              <div className="p-3 bg-muted rounded-lg space-y-1">
                <p className="text-xs text-muted-foreground">Specialty</p>
                <p className="text-sm font-medium">{review[2]}</p>
              </div>
            </div>
          </div>
        )}

        {/* Cast Vote Section (for council members) */}
        <div className="space-y-4 pt-4 border-t">
          <h3 className="text-sm font-semibold flex items-center gap-2">
            <MessageSquare className="h-4 w-4" />
            Cast Your Vote (Council Members Only)
          </h3>

          <div className="space-y-3">
            <div className="space-y-2">
              <label className="text-sm font-medium">Review ID</label>
              <input
                type="number"
                value={reviewId?.toString() || ''}
                onChange={(e) => setReviewId(BigInt(e.target.value || 0))}
                placeholder="Enter review ID"
                className="w-full px-3 py-2 border rounded-md text-sm"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Your Decision</label>
              <div className="flex gap-2">
                <Button
                  onClick={() => setVote(true)}
                  variant={vote === true ? 'default' : 'outline'}
                  className="flex-1"
                >
                  Approve
                </Button>
                <Button
                  onClick={() => setVote(false)}
                  variant={vote === false ? 'destructive' : 'outline'}
                  className="flex-1"
                >
                  Reject
                </Button>
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Feedback</label>
              <textarea
                value={feedback}
                onChange={(e) => setFeedback(e.target.value)}
                placeholder="Provide detailed feedback for your decision..."
                className="w-full px-3 py-2 border rounded-md text-sm min-h-[80px]"
              />
            </div>

            <Button 
              onClick={handleCastVote} 
              disabled={isVoting || vote === null}
              className="w-full"
            >
              {isVoting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Submitting...
                </>
              ) : (
                'Submit Vote & Feedback'
              )}
            </Button>
          </div>
        </div>

        {/* Info */}
        <div className="text-xs text-muted-foreground p-3 bg-muted/50 rounded-lg">
          <p>Council members are compensated 50 CRED per review. Quorum requires 66% of specialty members to vote.</p>
        </div>
      </CardContent>
    </Card>
  );
}
