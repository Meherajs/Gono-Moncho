# 🗞️ Gono Moncho User Guide

**The Decentralized, Verifiable, and Trustworthy News Platform**

---

## 📚 Table of Contents

1. [What is Gono Moncho?](#what-is-gono-moncho)
2. [Getting Started](#getting-started)
3. [Understanding the Homepage](#understanding-the-homepage)
4. [Wallet Connection](#wallet-connection)
5. [User Roles Explained](#user-roles-explained)
6. [Reading Articles](#reading-articles)
7. [Publishing Articles (Journalists)](#publishing-articles-journalists)
8. [Verifying Articles (Verifiers)](#verifying-articles-verifiers)
9. [Governance & DAO](#governance--dao)
10. [Staking System](#staking-system)
11. [Voting Delegation](#voting-delegation)
12. [Technical Features](#technical-features)
13. [FAQ](#faq)

---

## What is Gono Moncho?

### 🎯 The Problem We Solve

In today's digital age, misinformation spreads rapidly, and it's hard to know which news sources to trust. Traditional news platforms have centralized control, making them vulnerable to censorship, bias, and manipulation.

### 💡 Our Solution

**Gono Moncho** (meaning "People's Platform" in Bengali) is a **blockchain-based decentralized news platform** where:

- 📰 **Journalists publish** verified news on-chain
- 🔍 **Community verifies** article authenticity
- 🤖 **AI assists** in credibility scoring
- 🏛️ **DAO governance** ensures democratic control
- 🔗 **Blockchain** ensures transparency and immutability

### ✨ Key Features

- **Decentralized Publishing**: No single authority controls what gets published
- **Community Verification**: Readers verify articles through staking and voting
- **Credibility Scores**: Each article gets a trustworthiness score
- **Permanent Storage**: Articles stored on Arweave (permanent decentralized storage)
- **Token Economics**: Reward good journalism, penalize misinformation
- **DAO Governance**: Community decides platform rules and policies

---

## Getting Started

### Prerequisites

Before using Gono Moncho, you need:

1. **MetaMask Wallet** (Browser Extension)
   - Download from: [metamask.io](https://metamask.io)
   - Create a new wallet or import existing one
   - Save your seed phrase securely!

2. **Polygon Amoy Testnet** (Test Network)
   - Network Name: `Polygon Amoy`
   - RPC URL: `https://rpc-amoy.polygon.technology/`
   - Chain ID: `80002`
   - Currency Symbol: `POL`
   - Block Explorer: `https://amoy.polygonscan.com/`

3. **Test POL Tokens** (for gas fees)
   - Get free test POL from: [Polygon Faucet](https://faucet.polygon.technology/)
   - You'll need POL to pay transaction fees

### First-Time Setup

1. **Open Gono Moncho** → Navigate to `localhost:3000` (or the deployed URL)
2. **Connect Your Wallet** → Click "Connect" button in top-right
3. **Select MetaMask** → Approve the connection
4. **Switch to Polygon Amoy** → MetaMask will prompt you to switch networks

✅ You're now connected and can explore the platform!

---

## Understanding the Homepage

### 🏠 Homepage Layout

When you first visit Gono Moncho, you'll see:

```
┌─────────────────────────────────────────────────────────────┐
│  📅 Date    🏛️ Governance   ✍️ Publish   👤 0x6BA...643    │  ← Top Bar (Sticky)
├─────────────────────────────────────────────────────────────┤
│                                                               │
│                    Gono Moncho                               │  ← Hero Section
│        DECENTRALIZED • VERIFIABLE • TRUSTWORTHY              │
│                                                               │
├─────────────────────────────────────────────────────────────┤
│  All | National | Business | Tech | Entertainment | Sports  │  ← Category Tabs (Sticky)
└─────────────────────────────────────────────────────────────┘

┌──────────────────┬──────────────┬──────────────┐
│                  │              │              │
│   Main Story     │  Story 2     │  Story 3     │  ← Article Grid
│   (Large)        │  (Medium)    │  (Small)     │
│                  │              │              │
└──────────────────┴──────────────┴──────────────┘
```

### 📍 Navigation Elements

#### 1. **Top Bar** (Always visible when scrolling)
- **Date**: Current date display
- **Governance**: Access DAO voting and proposals
- **Publish Article**: Only visible if you're a staked journalist
- **Wallet Address**: Shows your connected wallet (shortened)
- **Connect/Disconnect Button**: Manage wallet connection

#### 2. **Hero Section** (Scrolls away)
- **Gono Moncho Logo**: Click to return to "All" articles view
- **Tagline**: Platform mission statement

#### 3. **Category Navigation** (Sticks below top bar)
- **All**: Shows every article (default view)
- **National**: Bangladesh national news
- **Business**: Economic and financial news
- **Tech & Startup**: Technology and innovation
- **Entertainment**: Culture and entertainment
- **Sports**: Sports news and updates
- **World**: International news

### 🎨 Article Card Types

Articles appear in different sizes based on importance:

#### **Hero Card** (Largest)
- Full-width featured article
- Large image
- Full headline and summary
- Status badge (Verified/Pending)

#### **Medium Card**
- Medium-sized image
- Full headline
- Short summary
- Author and status

#### **Compact Card**
- Small image
- Headline only
- Quick status indicator

---

## Wallet Connection

### 🔐 Why Connect Your Wallet?

Your wallet is your **identity** on Gono Moncho. Without it, you can:
- ✅ Browse articles
- ✅ Read content
- ✅ View credibility scores

With a connected wallet, you can:
- ✅ **Stake tokens** to become a journalist
- ✅ **Publish articles**
- ✅ **Verify articles** (vote on credibility)
- ✅ **Participate in governance**
- ✅ **Delegate voting power**

### 📱 How to Connect

1. **Click "Connect" Button** (Top-right corner)
2. **MetaMask Pop-up Appears**
   ```
   Allow this site to:
   ☑ View your account address
   ☑ Request approval for transactions
   ```
3. **Click "Connect"**
4. **Wallet Address Appears** in header (e.g., `0x6BA2...e643`)

### 🔄 Network Switching

If you're on the wrong network, Gono Moncho will show:

```
⚠️ Wrong Network
Please switch to Polygon Amoy
```

**To Switch:**
1. Click the warning
2. MetaMask asks: "Allow this site to switch the network?"
3. Click "Switch network"

### 🚪 Disconnecting

**To Disconnect:**
1. Click "Disconnect" button
2. You'll remain connected in MetaMask
3. To fully disconnect, open MetaMask → Settings → Connected Sites → Remove

---

## User Roles Explained

Gono Moncho has **three user roles** based on token holdings:

### 👤 Reader (Default)

**Who:** Anyone visiting the platform  
**Requirements:** None (no tokens needed)

**What You Can Do:**
- ✅ Browse all articles
- ✅ Read full content
- ✅ View credibility scores
- ✅ Check verification status
- ❌ Cannot publish articles
- ❌ Cannot verify articles
- ❌ Cannot vote on proposals

**How to Get Started:**
Just visit the website! No wallet needed for reading.

---

### ✍️ Journalist

**Who:** Content creators who publish articles  
**Requirements:** Must **stake NEWS tokens**

**What You Can Do:**
- ✅ **Publish articles** to the blockchain
- ✅ Upload text, images, and videos
- ✅ Earn credibility reputation
- ✅ All Reader privileges

**How to Become a Journalist:**

1. **Get NEWS Tokens**
   - Option 1: Use token faucet (if available)
   - Option 2: Ask backend team to send you tokens
   - Option 3: Buy from decentralized exchange (mainnet only)

2. **Go to Governance Page**
   - Click "🏛️ Governance" in top bar
   - Scroll to "Staking Section"

3. **Stake NEWS Tokens**
   ```
   ┌─────────────────────────────────────┐
   │  💰 Staking Section                 │
   ├─────────────────────────────────────┤
   │  Your NEWS Balance: 1000.00         │
   │                                     │
   │  Amount to Stake: [________] NEWS  │
   │                                     │
   │  [Approve] [Stake]                 │
   └─────────────────────────────────────┘
   ```

4. **Two-Step Process:**
   - **Step 1: Approve** → Allow contract to use your tokens
     - Click "Approve"
     - Confirm in MetaMask
     - Wait for transaction (~5 seconds)
   
   - **Step 2: Stake** → Lock your tokens
     - Click "Stake"
     - Confirm in MetaMask
     - Wait for transaction (~5 seconds)

5. **Success!** 🎉
   - "✍️ Publish Article" button appears in header
   - You can now publish articles

**Why Stake?**
- Proves commitment to quality journalism
- Acts as collateral (can be slashed for misinformation)
- Required to access publishing features

---

### 🔍 Verifier/Analyzer

**Who:** Community members who verify article authenticity  
**Requirements:** Must have **CRED tokens**

**What You Can Do:**
- ✅ **Vote on articles** (Verify or Flag)
- ✅ Earn rewards for accurate verification
- ✅ Participate in DAO governance
- ✅ All Reader privileges

**How to Become a Verifier:**

1. **Get CRED Tokens**
   - Earn by staking NEWS tokens (automatic over time)
   - Use token faucet (if available)
   - Participate in governance

2. **Verify Articles**
   - Open any article
   - Scroll to "Cast Your Vote" section
   - Click "✅ Verify" or "🚩 Flag"

**What are CRED Tokens?**
- **Non-transferable** (Soulbound tokens)
- Represent your **reputation** and **verification power**
- Earned through good behavior
- Lost through bad behavior (slashing)

---

## Reading Articles

### 📖 How to Browse Articles

#### **From Homepage:**

1. **Filter by Category**
   - Click any category tab (National, Business, etc.)
   - Articles instantly filter
   - Category button highlights in blue

2. **View All Articles**
   - Click "All" tab
   - Or click "Gono Moncho" logo

3. **Click Article Card**
   - Click anywhere on the article card
   - Opens full article detail page

#### **Article Detail Page:**

```
┌─────────────────────────────────────────────────────────┐
│  🏠 Home › National                              ← Breadcrumb
├─────────────────────────────────────────────────────────┤
│                                                           │
│  🏷️ NATIONAL                                              │
│                                                           │
│  Bangladesh, Malaysia sign eight deals                   │
│  to boost bilateral cooperation                          │
│                                                           │
│  👤 Jane Doe              ✅ Verified    ⭐ Score: 85     │
│     Verified Journalist                                   │
│                                                           │
├─────────────────────────────────────────────────────────┤
│  📸 Article Image/Video                                   │
├─────────────────────────────────────────────────────────┤
│  📝 Article Content                                       │
│     The signing ceremony took place in Putrajaya         │
│     this morning, witnessed by prominent figures...      │
│                                                           │
├─────────────────────────────────────────────────────────┤
│  🤖 AI Credibility Analysis                               │
│     Score: 85/100 - High Credibility                     │
├─────────────────────────────────────────────────────────┤
│  🗳️ Cast Your Vote (Verifiers Only)                       │
│     [✅ Verify Article] [🚩 Flag as Misinformation]      │
│                                                           │
│     Current Votes: 12 Verified, 2 Flagged                │
└─────────────────────────────────────────────────────────┘
```

### 🔍 Understanding Article Information

#### **Status Badges:**

- **✅ Human Verified** (Green)
  - Community has verified this article
  - High confidence in authenticity
  - Multiple verifiers have approved

- **🤖 AI Verified** (Blue)
  - AI analysis completed
  - Awaiting human verification
  - Preliminary credibility check passed

- **⏳ Pending** (Yellow)
  - Recently published
  - Verification in progress
  - No verdict yet

- **⚠️ Disputed** (Red)
  - Community flagged potential issues
  - Mixed verification results
  - Read with caution

#### **Credibility Score:**

Scale: **0-100**
- **80-100**: High Credibility (Green) ✅
- **60-79**: Moderate Credibility (Blue) 📘
- **40-59**: Low Credibility (Yellow) ⚠️
- **0-39**: Very Low Credibility (Red) 🚫

**How It's Calculated:**
1. AI analysis (preliminary score)
2. Community votes (weighted by CRED holdings)
3. SANUB algorithm (combines AI + human input)
4. Historical accuracy of verifiers

#### **Author Information:**

```
👤 By Jane Doe
   Verified Journalist
```

- Shows Ethereum address or profile name
- "Verified Journalist" badge confirms staking
- Click to see author's other articles (future feature)

---

## Publishing Articles (Journalists)

### ✍️ Prerequisites

Before publishing, ensure:
- ✅ Wallet connected
- ✅ On Polygon Amoy network
- ✅ NEWS tokens staked
- ✅ "Publish Article" button visible in header

### 📝 Step-by-Step Publishing Guide

#### **Step 1: Access Publish Page**

1. Click **"✍️ Publish Article"** in top bar
2. You'll see the publishing form

```
┌─────────────────────────────────────────────────────────┐
│  ✍️ Publish New Article                                  │
├─────────────────────────────────────────────────────────┤
│  Article Headline *                                       │
│  [________________________________]                      │
│                                                           │
│  Article Content *                                        │
│  [________________________________]                      │
│  [________________________________]                      │
│  [________________________________]                      │
│                                                           │
│  📸 Upload Video (Optional)                               │
│  [Choose File]                                            │
│                                                           │
│  [Publish to Blockchain]                                 │
└─────────────────────────────────────────────────────────┘
```

#### **Step 2: Fill in Article Details**

1. **Headline** (Required)
   - Clear, descriptive title
   - 5-100 characters
   - Example: "Bangladesh GDP grows 7.2% in Q3 2025"

2. **Content** (Required)
   - Full article body
   - Support markdown formatting
   - Minimum 50 characters
   - Example:
   ```
   The Bangladesh economy showed strong growth in the
   third quarter of 2025, with GDP expanding by 7.2%
   compared to the same period last year...
   ```

3. **Video** (Optional)
   - Upload supporting video
   - Formats: MP4, WebM, MOV
   - Max size: 100MB (recommended)
   - Stores locally (blockchain stores reference)

#### **Step 3: Publish to Blockchain**

1. **Click "Publish to Blockchain"**

2. **MetaMask Popup Appears**
   ```
   Contract Interaction
   
   Function: publishNews
   Gas Fee: ~0.01 POL
   
   [Reject] [Confirm]
   ```

3. **Review Transaction:**
   - Contract: Verification Contract
   - Function: `publishNews(contentHash)`
   - Content Hash: Unique identifier for your article

4. **Click "Confirm"**

5. **Wait for Confirmation** (5-10 seconds)
   - Status: "Publishing article to blockchain..."
   - Transaction submits to network
   - Miners process transaction

6. **Success! 🎉**
   ```
   ✅ Article published successfully!
      Redirecting to homepage...
   ```

7. **Your Article Appears**
   - Automatically added to homepage
   - Status: "Pending"
   - Visible to all users immediately

#### **Step 4: Share Your Article**

- Copy URL from browser
- Share on social media
- Community begins verification

---

### 📊 What Happens After Publishing?

#### **Immediate:**
1. Article stored on blockchain (permanent record)
2. Content hash generated (unique identifier)
3. Status set to "Pending"
4. Appears on homepage

#### **Within Minutes:**
1. AI analysis begins (if AI Oracle configured)
2. Preliminary credibility score assigned
3. Status may update to "AI Verified"

#### **Within Hours:**
1. Community members see your article
2. Verifiers start voting (Verify/Flag)
3. Credibility score adjusts based on votes
4. Status updates to "Human Verified" or "Disputed"

#### **Long Term:**
1. Your reputation builds with quality articles
2. Earn CRED tokens for verified content
3. Risk slashing for misinformation
4. Build journalist portfolio

---

### ⚠️ Important Publishing Guidelines

#### **Do's ✅**
- ✅ Fact-check before publishing
- ✅ Cite sources when possible
- ✅ Use clear, objective language
- ✅ Include relevant images/videos
- ✅ Proofread for errors

#### **Don'ts ❌**
- ❌ Publish false information
- ❌ Plagiarize content
- ❌ Use clickbait headlines
- ❌ Include hate speech
- ❌ Violate copyright

#### **Consequences:**
- **Good Articles**: Earn reputation, CRED tokens, community trust
- **Bad Articles**: Lose CRED, risk staking penalty (slashing), platform bans

---

## Verifying Articles (Verifiers)

### 🔍 Why Verification Matters

**You are the quality control** for Gono Moncho. Every vote you cast:
- Helps filter truth from misinformation
- Protects the community
- Earns you reputation (CRED tokens)
- Shapes the credibility score

### ✅ How to Verify Articles

#### **Step 1: Find an Article to Verify**

1. Browse homepage for articles
2. Look for:
   - ⏳ "Pending" status (needs verification)
   - 🤖 "AI Verified" (needs human confirmation)
   - Low vote counts

3. Click article to open detail page

#### **Step 2: Read and Analyze**

**Before Voting, Ask:**

📋 **Content Checklist:**
- [ ] Is the headline accurate?
- [ ] Does the content match the headline?
- [ ] Are facts verifiable?
- [ ] Are sources cited?
- [ ] Is the writing quality good?
- [ ] Is there bias or propaganda?
- [ ] Are images/videos relevant?

🚩 **Red Flags:**
- Sensational or clickbait headlines
- No sources provided
- Poor grammar/spelling
- Emotional manipulation
- Unverifiable claims
- Contradicts known facts

#### **Step 3: Cast Your Vote**

Scroll to **"Cast Your Vote"** section:

```
┌─────────────────────────────────────────────────────────┐
│  🗳️ Cast Your Vote                                       │
├─────────────────────────────────────────────────────────┤
│  Help verify this article's authenticity.               │
│  Your vote directly influences the credibility score.   │
│                                                           │
│  Current Votes: ✅ 8 Verified  🚩 2 Flagged              │
│                                                           │
│  ┌──────────────────┐  ┌──────────────────┐             │
│  │  ✅ Verify       │  │  🚩 Flag as      │             │
│  │  Article         │  │  Misinformation  │             │
│  └──────────────────┘  └──────────────────┘             │
└─────────────────────────────────────────────────────────┘
```

**Option 1: ✅ Verify Article**
- Click if article is credible
- Adds score of 100 to verification
- Increases credibility rating

**Option 2: 🚩 Flag as Misinformation**
- Click if article is false/misleading
- Adds score of 0 to verification
- Decreases credibility rating

#### **Step 4: Confirm Transaction**

1. **MetaMask Popup Appears**
   ```
   Contract Interaction
   
   Function: addVerifierScore
   Parameters: 
     - contentHash: "0x1234..."
     - score: 100 (or 0)
   
   Gas Fee: ~0.005 POL
   
   [Reject] [Confirm]
   ```

2. **Click "Confirm"**

3. **Wait for Transaction** (5-10 seconds)

4. **Success! ✅**
   ```
   Transaction confirmed!
   Article verification updated.
   ```

5. **Vote Counted**
   - Your vote is recorded on blockchain
   - Credibility score recalculates
   - Vote count updates

---

### 📊 Understanding Verification Results

#### **Vote Display:**

```
Current Status: ✅ Verified

Votes Breakdown:
  ✅ Verified: 12 votes
  🚩 Flagged: 3 votes

Credibility Score: 78/100
```

**How Status Changes:**

- **Pending → AI Verified**: AI analysis completes
- **AI Verified → Human Verified**: Majority verify
- **Any Status → Disputed**: Mixed votes, controversy detected

#### **Finalization:**

After sufficient votes, article status becomes **final**:
- High verification → "✅ Human Verified"
- High flags → "⚠️ Disputed"
- Cannot be changed afterward

---

### 🎯 Verification Best Practices

#### **1. Be Objective**
- Remove personal bias
- Focus on facts, not opinions
- Verify, don't assume

#### **2. Take Your Time**
- Read full article
- Check sources if provided
- Research claims if doubtful

#### **3. Be Consistent**
- Apply same standards to all articles
- Don't vote randomly
- Build your reputation

#### **4. Stay Informed**
- Understand current events
- Know fact-checking resources
- Learn to spot misinformation

#### **5. Earn Rewards**
- Accurate verifications earn CRED
- Build verification reputation
- Unlock governance privileges

---

### ⚠️ Verification Penalties

**Bad Behavior:**
- Random voting without reading
- Always verifying/flagging everything
- Coordinated attacks on journalists

**Consequences:**
- CRED tokens slashed
- Reduced voting power
- Potential platform ban

---

## Governance & DAO

### 🏛️ What is DAO Governance?

**DAO** = Decentralized Autonomous Organization

Gono Moncho is **community-owned and community-governed**. No single person or company controls the platform. Instead:
- **Token holders vote** on important decisions
- **Smart contracts execute** approved changes automatically
- **Transparent process** recorded on blockchain

### 🎯 What Can Governance Control?

The DAO votes on:
- 💰 **Treasury Management**: How to spend platform funds
- ⚙️ **Parameter Changes**: Staking requirements, verification thresholds
- 🚨 **Emergency Actions**: Pause contracts, ban malicious actors
- 📋 **General Governance**: Platform policies, new features

### 🗳️ Accessing Governance

1. **Click "🏛️ Governance"** in top bar
2. **Governance Dashboard Opens:**

```
┌─────────────────────────────────────────────────────────┐
│  🏛️ DAO Governance                                       │
├─────────────────────────────────────────────────────────┤
│  Your Voting Power: 150 CRED                             │
│  Eligible to Vote: ✓                                     │
│  Active Proposals: 3                                     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  💰 Staking Section                                       │
│  (Stake NEWS to become journalist)                       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  🤝 Voting Delegation                                     │
│  (Delegate your voting power to another address)        │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  ✨ Create New Proposal                                   │
│  (Submit proposal for community vote)                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  📊 Active Proposals                                      │
│  (Vote on ongoing proposals)                             │
└─────────────────────────────────────────────────────────┘
```

---

### 📝 Creating a Proposal

#### **Prerequisites:**
- ✅ Connected wallet
- ✅ Have CRED tokens (voting power)

#### **Steps:**

1. **Scroll to "Create New Proposal" Section**

2. **Select Proposal Type:**
   ```
   📋 Proposal Type:
   ( ) General Governance
   ( ) Parameter Change
   ( ) Emergency Action
   ( ) Treasury Management
   ```

   **Types Explained:**
   - **General Governance**: Platform policies, feature requests
   - **Parameter Change**: Adjust staking amounts, verification thresholds
   - **Emergency Action**: Urgent security measures
   - **Treasury Management**: Fund allocation, budgets

3. **Click "Create Proposal"**

4. **Confirm Transaction in MetaMask**
   - Gas fee: ~0.01 POL
   - Wait for confirmation

5. **Proposal Created! 🎉**
   - Appears in "Active Proposals"
   - Voting period begins (typically 3 days)
   - Community can now vote

---

### 🗳️ Voting on Proposals

#### **View Active Proposals:**

```
┌─────────────────────────────────────────────────────────┐
│  Proposal #1: Increase Minimum Staking Requirement      │
│  Type: Parameter Change                                  │
│  Proposed by: 0x1234...5678                             │
│                                                           │
│  ✅ For: 1,250 votes                                      │
│  ❌ Against: 340 votes                                    │
│                                                           │
│  Time Remaining: 2 days, 14 hours                       │
│                                                           │
│  Your Vote: [For] [Against]                             │
│  Vote Amount: [___] CRED                                 │
└─────────────────────────────────────────────────────────┘
```

#### **How to Vote:**

1. **Read Proposal Details**
   - Understand what's being proposed
   - Consider pros and cons
   - Check community discussion

2. **Decide Your Position**
   - **For**: Support the proposal
   - **Against**: Oppose the proposal

3. **Enter Vote Amount**
   - Amount of CRED to commit
   - More CRED = More voting power
   - Tokens not locked (remain usable)

4. **Click "For" or "Against"**

5. **Confirm in MetaMask**
   - Transaction includes your vote
   - Gas fee: ~0.005-0.01 POL

6. **Vote Recorded ✅**
   - Your vote counts immediately
   - Can't change vote once cast
   - Results update in real-time

---

### ⚖️ Quadratic Voting

For **funding proposals**, Gono Moncho uses **Quadratic Voting**:

**How It Works:**
- Cost = votes²
- 1 vote costs 1 CRED
- 2 votes cost 4 CRED
- 3 votes cost 9 CRED
- 10 votes cost 100 CRED

**Why Quadratic?**
- Prevents "whale" domination
- Small holders have more influence
- Encourages coalition building
- More democratic outcomes

**Example:**
```
You want to cast 5 votes on a funding proposal:
Cost = 5² = 25 CRED tokens

Your staked tokens will be reduced by 25 CRED
(This is called "slashing" for voting)
```

---

### 📊 Proposal Lifecycle

```
1. Creation
   ↓ (Proposal submitted)
   
2. Voting Period (3 days)
   ↓ (Community votes)
   
3. Tallying
   ↓ (Count votes)
   
4. Execution or Rejection
   ↓ (If passed: execute | If failed: reject)
   
5. Complete
   (On-chain record permanent)
```

**Passing Requirements:**
- More "For" votes than "Against"
- Minimum quorum met (typically 10% of supply)
- Voting period expired

---

## Staking System

### 💰 What is Staking?

**Staking** = Locking your NEWS tokens as collateral

**Purpose:**
- Proves commitment to platform
- Unlocks journalist privileges
- Acts as security deposit
- Can be slashed for bad behavior

### 🎯 Why Stake NEWS Tokens?

**Benefits:**
1. ✍️ **Publish Articles**: Become a verified journalist
2. 💎 **Earn CRED**: Receive credibility tokens over time
3. 🏆 **Build Reputation**: Establish yourself as trusted source
4. 🎁 **Future Rewards**: Potential token rewards for quality content

**Risks:**
1. ⚠️ **Slashing**: Lose tokens for publishing misinformation
2. 🔒 **Locked Funds**: Tokens not available while staked
3. 📉 **Reputation Damage**: Bad articles harm your credibility

---

### 📈 How to Stake

Already covered in [User Roles → Journalist](#-journalist), but here's a quick reference:

1. **Go to Governance Page**
2. **Scroll to Staking Section**
3. **Enter Amount** (Minimum: usually 100 NEWS)
4. **Step 1: Approve** → Allow contract access
5. **Step 2: Stake** → Lock your tokens
6. **Success!** → Publishing unlocked

---

### 🔄 How to Unstake

Want to withdraw your staked tokens?

1. **Go to Governance Page**
2. **Scroll to Staking Section**
3. **View Your Staked Amount:**
   ```
   Your Staked Amount: 1000 NEWS
   Staked Since: Nov 20, 2025
   ```

4. **Enter Unstake Amount**
   ```
   Amount to Unstake: [___] NEWS
   ```

5. **Click "Unstake"**

6. **Confirm in MetaMask**

7. **Tokens Returned** to your wallet

**⚠️ Important:**
- Can only unstake what you've staked
- May have cooldown period (check platform rules)
- Lose journalist privileges if unstaking all

---

### 📊 Staking Statistics

View your staking info:

```
┌─────────────────────────────────────────────────────────┐
│  💰 Your Staking Statistics                              │
├─────────────────────────────────────────────────────────┤
│  NEWS Token Balance: 5,000                               │
│  Currently Staked: 1,000 NEWS                            │
│  CRED Earned: 150 CRED                                   │
│  Staking Duration: 42 days                               │
│  Articles Published: 8                                   │
│  Average Credibility: 82/100                             │
└─────────────────────────────────────────────────────────┘
```

---

## Voting Delegation

### 🤝 What is Delegation?

**Delegation** = Giving your voting power to someone else

**Why Delegate?**
- Don't have time to review all proposals
- Trust someone else's judgment
- Want expert to represent you
- Participate without active voting

**How It Works:**
- You keep your CRED tokens
- Someone else votes with your power
- Can undelegate anytime
- Your tokens never transfer

---

### 📋 How to Delegate Your Votes

1. **Go to Governance Page**

2. **Scroll to "Voting Delegation" Section:**
   ```
   ┌─────────────────────────────────────────────────────────┐
   │  🤝 Voting Delegation                                    │
   ├─────────────────────────────────────────────────────────┤
   │  Your Voting Power: 150 CRED                             │
   │  Current Delegate: None                                  │
   │                                                           │
   │  Delegate Address:                                       │
   │  [0x_________________________________]                   │
   │                                                           │
   │  [Delegate Votes]                                       │
   └─────────────────────────────────────────────────────────┘
   ```

3. **Enter Delegate Address**
   - Paste Ethereum address (0x...)
   - Must be valid address
   - Cannot delegate to yourself

4. **Click "Delegate Votes"**

5. **Confirm in MetaMask**
   - Transaction sets delegation
   - Gas fee: ~0.005 POL

6. **Delegation Active! ✅**
   ```
   ✅ Delegation updated successfully!
   
   Current Delegate: 0x1234...5678
   Delegated Voting Power: 150 CRED
   ```

---

### 🔄 How to Undelegate

Want to take back your voting power?

1. **Go to Delegation Section**

2. **Current Status Shows:**
   ```
   Currently Delegating To: 0x1234...5678
   Delegated Power: 150 CRED
   ```

3. **Click "Undelegate"**

4. **Confirm in MetaMask**

5. **Delegation Removed ✅**
   ```
   Delegation removed successfully!
   You can now vote directly.
   ```

---

### 💡 Delegation Best Practices

**Choosing a Delegate:**
- ✅ Check their voting history
- ✅ Verify they're active on platform
- ✅ Ensure they share your values
- ✅ Monitor their votes regularly

**Security:**
- ❌ Never delegate to unknown addresses
- ❌ Don't delegate to obvious scammers
- ✅ Can undelegate instantly if needed
- ✅ Your tokens remain in your wallet

---

## Technical Features

### 🔗 Blockchain Integration

#### **Smart Contracts (Polygon Amoy)**

Gono Moncho uses 7 interconnected smart contracts:

1. **NEWS Token** (`0xd3091433...`)
   - ERC20 governance token
   - Used for staking
   - Enables journalist access
   - Transferable

2. **CRED Token** (`0x95e29667...`)
   - ERC20 reputation token
   - Soulbound (non-transferable)
   - Earned through good behavior
   - Used for voting power

3. **NewsStaking** (`0x58321d7c...`)
   - Manages NEWS token staking
   - Tracks journalist status
   - Handles slashing
   - Distributes CRED rewards

4. **Verification** (`0xe5672b7b...`)
   - Stores article references
   - Tracks verification votes
   - Calculates credibility scores
   - Manages article status

5. **NewsDAO** (`0xccf0212b...`)
   - Governance proposals
   - Voting mechanism
   - Quadratic voting for funding
   - Proposal execution

6. **DelegationRegistry** (`0xea67b90c...`)
   - Vote delegation
   - Delegator tracking
   - Topic-based delegation

7. **ArweaveStorage** (`0xc7311a7c...`)
   - Arweave reference storage
   - Content ownership tracking

---

### 📦 Arweave Permanent Storage

**What is Arweave?**
- Permanent decentralized storage
- Pay once, store forever
- Censorship-resistant
- Immutable content

**How Gono Moncho Uses Arweave:**
1. Article content uploaded to Arweave
2. Arweave returns transaction ID (hash)
3. Hash stored on Polygon blockchain
4. Frontend fetches content using hash

**Benefits:**
- Articles can't be deleted
- No central server can go down
- Truly decentralized publishing
- Historical record preservation

---

### 🤖 AI Oracle Integration

**AI Oracle** (Planned Feature)

**What It Does:**
- Analyzes article content
- Checks for misinformation patterns
- Provides preliminary credibility score
- Flags suspicious content

**How It Works:**
1. Article published on-chain
2. AI Oracle event triggered
3. Off-chain AI service processes content
4. Result written back to blockchain
5. Score visible to users

**Current Status:**
- Contract address: Placeholder (not deployed)
- Functionality: Available after backend setup
- Frontend: Already integrated and ready

---

### 🔐 Security Features

#### **Wallet Security**
- MetaMask handles private keys
- Never share seed phrase
- Confirm all transactions
- Check contract addresses

#### **Smart Contract Security**
- Audited code (OpenZeppelin standards)
- Minimal attack surface
- Upgradeable contracts
- Emergency pause functionality

#### **Data Security**
- Content on Arweave (immutable)
- References on blockchain (transparent)
- No centralized database
- Censorship-resistant

---

## FAQ

### 💬 General Questions

**Q: Is Gono Moncho free to use?**  
**A:** Reading is free. Publishing/verifying requires tokens and gas fees (POL).

**Q: Do I need cryptocurrency to read articles?**  
**A:** No! You can browse and read without any tokens or wallet.

**Q: What blockchain does Gono Moncho use?**  
**A:** Polygon Amoy testnet (for demo). Will use Polygon mainnet in production.

**Q: Can I edit or delete my articles?**  
**A:** No. Once published on blockchain, articles are permanent (immutable).

**Q: How long do articles stay on the platform?**  
**A:** Forever! Arweave storage is permanent.

---

### 🪙 Token Questions

**Q: How do I get NEWS tokens?**  
**A:** 
- Use token faucet (if available)
- Request from backend team
- Buy on DEX (mainnet only)

**Q: How do I get CRED tokens?**  
**A:** 
- Stake NEWS tokens (earn over time)
- Verify articles accurately
- Participate in governance

**Q: Can I sell my CRED tokens?**  
**A:** No. CRED is soulbound (non-transferable). It represents reputation.

**Q: What's the minimum to stake?**  
**A:** Typically 100 NEWS tokens (check platform for current requirement).

**Q: Can I lose my staked tokens?**  
**A:** Yes, through "slashing" if you publish misinformation.

---

### 📰 Publishing Questions

**Q: Who can publish articles?**  
**A:** Anyone who stakes NEWS tokens becomes a journalist.

**Q: Is there a limit to how many articles I can publish?**  
**A:** No limit! Publish as much quality content as you want.

**Q: What file formats are supported for uploads?**  
**A:** Images (JPG, PNG), Videos (MP4, WebM), Text (markdown).

**Q: How long does publishing take?**  
**A:** 5-10 seconds for blockchain confirmation.

**Q: Do I get paid for publishing?**  
**A:** Currently no direct payment. Future versions may include rewards.

---

### ✅ Verification Questions

**Q: Who can verify articles?**  
**A:** Anyone with CRED tokens can vote on articles.

**Q: Do I earn rewards for verifying?**  
**A:** Yes! Accurate verifications earn CRED reputation.

**Q: Can I change my vote?**  
**A:** No. Votes are final once confirmed on blockchain.

**Q: What happens if I vote incorrectly?**  
**A:** Consistently bad voting may result in CRED penalties.

**Q: How many votes does an article need?**  
**A:** No fixed number. More votes = more reliable score.

---

### 🏛️ Governance Questions

**Q: Who can create proposals?**  
**A:** Anyone with CRED tokens (voting power).

**Q: How long are voting periods?**  
**A:** Typically 3 days (varies by proposal type).

**Q: What happens if a proposal passes?**  
**A:** Smart contracts automatically execute the approved changes.

**Q: Can I vote on multiple proposals?**  
**A:** Yes! Vote on as many as you want.

**Q: Is my vote public?**  
**A:** Yes. All votes are recorded on blockchain (transparent).

---

### 🔧 Technical Questions

**Q: What wallets are supported?**  
**A:** MetaMask (primary). Other Web3 wallets may work.

**Q: Why do I need test POL?**  
**A:** To pay gas fees for blockchain transactions.

**Q: What's a gas fee?**  
**A:** Small fee paid to blockchain miners to process transactions.

**Q: Is my data private?**  
**A:** No. All data on blockchain is public and permanent.

**Q: Can the platform be shut down?**  
**A:** No. Decentralized and on blockchain. No central point of failure.

**Q: What if MetaMask is hacked?**  
**A:** Use hardware wallet, enable 2FA, never share seed phrase.

---

### 🐛 Troubleshooting

**Q: Transaction failed. What do I do?**  
**A:** 
1. Check POL balance (need gas)
2. Verify network (Polygon Amoy)
3. Try increasing gas limit
4. Check MetaMask activity log

**Q: Article not appearing after publish?**  
**A:** 
1. Wait 30 seconds and refresh
2. Check transaction on block explorer
3. Ensure transaction confirmed
4. Clear browser cache

**Q: Can't connect wallet?**  
**A:**
1. Refresh page
2. Check MetaMask unlocked
3. Verify correct network
4. Try different browser

**Q: Buttons not working?**  
**A:**
1. Check wallet connected
2. Verify correct network
3. Ensure sufficient tokens
4. Check browser console for errors

---

## 🎓 For Hackathon Judges/Mentors

### 🎯 Project Overview

**Gono Moncho** demonstrates:

1. **Full-Stack Blockchain Development**
   - 7 interconnected smart contracts
   - Solidity best practices
   - OpenZeppelin standards
   - Upgradeable architecture

2. **Modern Web3 Frontend**
   - Next.js 14 (App Router)
   - Wagmi v2 hooks
   - TypeScript
   - Tailwind CSS
   - Real-time blockchain data

3. **Decentralized Architecture**
   - No central server for content
   - Arweave permanent storage
   - Blockchain-based verification
   - DAO governance

4. **Token Economics**
   - Dual token system (NEWS/CRED)
   - Staking mechanism
   - Slashing for bad behavior
   - Quadratic voting

5. **AI Integration** (Planned)
   - Chainlink oracles
   - Off-chain computation
   - On-chain verification
   - Hybrid credibility scoring

---

### 🏆 Key Innovation Points

1. **SANUB Algorithm**: Novel credibility scoring combining AI + human input
2. **Soulbound Reputation**: Non-transferable CRED tokens prevent market manipulation
3. **Quadratic Voting**: Democratic governance preventing whale domination
4. **Permanent Storage**: Arweave integration for censorship resistance
5. **Role-Based Access**: Smart contract enforced journalist verification

---

### 📊 Technical Highlights

**Smart Contract Architecture:**
```
NEWS Token ←→ NewsStaking ←→ Verification
     ↓              ↓              ↓
  CRED Token ←→ NewsDAO ←→ AI Oracle
     ↓              ↓
DelegationRegistry ←→ ArweaveStorage
```

**Frontend Stack:**
- Next.js 14 (React Server Components)
- Wagmi + Viem (Ethereum interaction)
- TanStack Query (State management)
- Polygon Amoy (Test network)

**Key Features Implemented:**
- ✅ Wallet connection (MetaMask)
- ✅ Token staking/unstaking
- ✅ Article publishing on-chain
- ✅ Community verification voting
- ✅ DAO governance proposals
- ✅ Vote delegation
- ✅ Real-time credibility scoring
- ⏳ AI Oracle (ready for integration)
- ⏳ Arweave upload (ready for API)

---

### 🚀 Demo Flow for Judges

**5-Minute Demo Script:**

1. **Homepage** (30 sec)
   - Show article grid
   - Filter by categories
   - Explain credibility scores

2. **Wallet Connection** (30 sec)
   - Connect MetaMask
   - Show network indicator
   - Explain Polygon Amoy

3. **Staking** (1 min)
   - Navigate to Governance
   - Approve + Stake NEWS tokens
   - Become journalist

4. **Publishing** (1 min)
   - Go to Publish page
   - Fill article form
   - Submit to blockchain
   - Show transaction confirmation

5. **Verification** (1 min)
   - Open article detail
   - Cast verification vote
   - Show updated credibility score

6. **Governance** (1 min)
   - Create proposal
   - Vote on existing proposal
   - Explain quadratic voting

7. **Architecture** (30 sec)
   - Show smart contracts on block explorer
   - Explain decentralized storage
   - Highlight no central point of failure

---

### 💡 Discussion Points

**For Technical Questions:**
- Solidity optimization techniques used
- Why Polygon over other L2s
- Arweave vs IPFS comparison
- Security considerations
- Scalability solutions

**For Business Questions:**
- Target market (developing countries)
- Monetization strategy
- Competitor analysis
- Growth roadmap
- Real-world adoption plan

**For Impact Questions:**
- Fighting misinformation
- Censorship resistance
- Empowering independent journalism
- Community-driven content moderation
- Democratic governance

---

## 📖 Glossary

**Blockchain Terms:**

- **Blockchain**: Distributed ledger technology
- **Smart Contract**: Self-executing code on blockchain
- **Gas Fee**: Transaction cost on blockchain
- **Wallet**: Digital account holding cryptocurrencies
- **MetaMask**: Popular browser wallet extension
- **Transaction**: Action on blockchain (costs gas)
- **Confirmation**: Transaction verified by miners
- **Block Explorer**: Website to view blockchain data

**Platform Terms:**

- **NEWS Token**: Governance token for staking
- **CRED Token**: Soulbound reputation token
- **Staking**: Locking tokens as collateral
- **Slashing**: Penalty removing staked tokens
- **Verification**: Community voting on article credibility
- **DAO**: Decentralized Autonomous Organization
- **Delegation**: Giving voting power to another user
- **Quadratic Voting**: Voting system where cost = votes²
- **Arweave**: Permanent decentralized storage
- **Content Hash**: Unique identifier for article
- **Credibility Score**: 0-100 rating of article trustworthiness

**User Roles:**

- **Reader**: Anyone browsing articles
- **Journalist**: Staked NEWS, can publish
- **Verifier**: Has CRED, can vote on articles
- **Delegate**: Votes on behalf of delegators

---

## 🎉 Conclusion

Congratulations! You now understand how to use Gono Moncho from beginning to end.

**Remember:**
- 📰 **Read** articles freely
- ✍️ **Stake** to become a journalist
- ✅ **Verify** to earn reputation
- 🗳️ **Vote** to govern the platform
- 🤝 **Delegate** if you're busy
- 🔗 **Participate** in building better journalism

**Join the Revolution:**
Gono Moncho isn't just a platform—it's a movement toward transparent, community-driven, censorship-resistant journalism.

**Your Voice Matters. Your Vote Counts. Your Truth Persists.**

---

*Built with ❤️ for Build4Democracy Hackathon*  
*Powered by Polygon, Arweave, and the Community*

**Questions? Issues? Feedback?**  
Open an issue on GitHub or contact the team.

---

## 📚 Additional Resources

**Official Links:**
- GitHub Repository: [github.com/ByzentineGenerals/Gono-Moncho](https://github.com/ByzentineGenerals/Gono-Moncho)
- Block Explorer: [amoy.polygonscan.com](https://amoy.polygonscan.com)
- Polygon Faucet: [faucet.polygon.technology](https://faucet.polygon.technology)

**Learn More:**
- [Polygon Documentation](https://docs.polygon.technology/)
- [MetaMask Guide](https://metamask.io/faqs/)
- [Arweave Documentation](https://docs.arweave.org/)
- [What is a DAO?](https://ethereum.org/en/dao/)
- [Understanding Gas Fees](https://ethereum.org/en/developers/docs/gas/)

**Video Tutorials:**
- How to Install MetaMask
- Getting Test Tokens
- Publishing Your First Article
- Verifying Articles Effectively
- Participating in DAO Governance

---

*Last Updated: November 25, 2025*  
*Version: 1.0*  
*For Gono Moncho v1.0*
