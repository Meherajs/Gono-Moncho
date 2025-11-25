# Arweave Integration Setup Guide

## 🎯 Current Status

✅ **Development Mode Active** - Mock Arweave uploads with simulated transaction IDs  
✅ **API Endpoint Ready** - `/api/arweave/upload` handles file and JSON uploads  
✅ **Frontend Integration** - PublishForm and ArweaveUploadHelper use the API  

## 🚀 Production Setup (Real Arweave)

### Step 1: Install Bundlr/Irys SDK

```bash
cd frontend
npm install @bundlr-network/client
# OR for Irys (formerly Bundlr)
npm install @irys/sdk
```

### Step 2: Get Arweave Wallet

1. Create an Arweave wallet at https://arweave.app/
2. Get AR tokens for uploads (pay-once permanent storage)
3. Export your wallet keyfile (JSON)

### Step 3: Set Environment Variables

Create `frontend/.env.local`:

```env
# Arweave/Bundlr Configuration
BUNDLR_NODE_URL=https://node2.bundlr.network
BUNDLR_CURRENCY=matic # or 'ethereum', 'arweave'
BUNDLR_PRIVATE_KEY=your_private_key_here

# Alternative: Use Arweave wallet
ARWEAVE_WALLET_KEY={"kty":"RSA",...}

# Optional: IPFS Fallback
IPFS_API_URL=https://api.nft.storage
IPFS_API_KEY=your_nft_storage_key
```

### Step 4: Update API Route

Replace the mock implementation in `frontend/src/app/api/arweave/upload/route.ts`:

```typescript
import { NextRequest, NextResponse } from 'next/server';
import Bundlr from '@bundlr-network/client';

const bundlr = new Bundlr(
  process.env.BUNDLR_NODE_URL!,
  process.env.BUNDLR_CURRENCY!,
  process.env.BUNDLR_PRIVATE_KEY!
);

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const file = formData.get('file') as File | null;
    const jsonData = formData.get('json') as string | null;

    let content: Buffer;
    let contentType: string;
    let tags: { name: string; value: string }[];

    if (file) {
      const arrayBuffer = await file.arrayBuffer();
      content = Buffer.from(arrayBuffer);
      contentType = file.type;
      tags = [
        { name: 'Content-Type', value: contentType },
        { name: 'App-Name', value: 'Gono-Moncho' },
        { name: 'App-Version', value: '1.0' },
        { name: 'File-Name', value: file.name },
      ];
    } else if (jsonData) {
      content = Buffer.from(jsonData, 'utf-8');
      contentType = 'application/json';
      tags = [
        { name: 'Content-Type', value: contentType },
        { name: 'App-Name', value: 'Gono-Moncho' },
        { name: 'Type', value: 'Article' },
      ];
    } else {
      return NextResponse.json(
        { error: 'No file or JSON data provided' },
        { status: 400 }
      );
    }

    // Upload to Arweave via Bundlr
    const tx = await bundlr.upload(content, { tags });

    return NextResponse.json({
      success: true,
      arweaveId: tx.id,
      arweaveUrl: `https://arweave.net/${tx.id}`,
      contentType,
      size: content.length,
      uploadedAt: new Date().toISOString(),
      txResponse: tx,
    });

  } catch (error) {
    console.error('Upload error:', error);
    return NextResponse.json(
      { error: 'Upload failed', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    );
  }
}
```

### Step 5: Fund Your Bundlr Account

```bash
# Fund with MATIC (Polygon)
npx @bundlr-network/client fund 1000000000000000000 -h https://node2.bundlr.network -w your_private_key -c matic

# Check balance
npx @bundlr-network/client balance your_address -h https://node2.bundlr.network -c matic
```

## 📊 Cost Estimation

**Arweave Storage Costs:**
- ~0.0000068 AR per KB (~$0.0001 per KB)
- Average article (5KB JSON): ~0.034 AR (~$0.50)
- Image (500KB): ~3.4 AR (~$50)
- Video (50MB): ~340 AR (~$5,000)

**Bundlr Simplifies:**
- Pay with MATIC, ETH, or other tokens
- Instant uploads (no waiting for AR confirmations)
- Guaranteed permanent storage

## 🔄 Alternative: IPFS Integration

For cheaper but less permanent storage:

```bash
npm install nft.storage
```

```typescript
import { NFTStorage, File } from 'nft.storage';

const client = new NFTStorage({ token: process.env.IPFS_API_KEY! });

const cid = await client.storeBlob(new Blob([content]));
const ipfsUrl = `https://ipfs.io/ipfs/${cid}`;
```

## 🧪 Testing

### Test with Development Mode

1. Start frontend: `npm run dev`
2. Go to Reporter Portal → Upload Content
3. Upload a file - see mock Arweave ID
4. Publish article - uses mock ID

### Test with Real Arweave

1. Set up environment variables
2. Update API route with Bundlr code
3. Fund Bundlr account
4. Upload file - see real Arweave transaction
5. Verify at: `https://arweave.net/YOUR_TX_ID`

## 📝 Contract Integration

The Verification contract expects an Arweave hash:

```solidity
function publishNews(string memory contentHash) external {
    // contentHash = Arweave transaction ID
    newsItems[contentHash] = NewsItem({
        reporter: msg.sender,
        arweaveHash: contentHash,
        // ... other fields
    });
}
```

## 🔐 Security Notes

1. **Never commit private keys** - Use environment variables
2. **Use server-side uploads** - Don't expose keys to frontend
3. **Validate content** - Check file types and sizes
4. **Rate limiting** - Prevent abuse of upload API
5. **Authentication** - Verify user wallet before allowing uploads

## 📚 Resources

- Bundlr Docs: https://docs.bundlr.network/
- Irys Docs: https://docs.irys.xyz/
- Arweave Docs: https://docs.arweave.org/
- NFT.Storage: https://nft.storage/

## ✅ Deployment Checklist

- [ ] Install Bundlr/Irys SDK
- [ ] Create Arweave wallet
- [ ] Set environment variables
- [ ] Update API route with real implementation
- [ ] Fund Bundlr account
- [ ] Test upload functionality
- [ ] Deploy to production
- [ ] Monitor upload costs
- [ ] Set up backup IPFS gateway

---

**Status:** Currently in development mode with mock uploads. Ready for production integration! 🚀
