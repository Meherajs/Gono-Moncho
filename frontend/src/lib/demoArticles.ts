// Demo Articles for Arweave
// These can be uploaded manually or through the UI

export const demoArticles = [
  {
    title: "Blockchain Technology Transforms Journalism in 2025",
    content: `In a groundbreaking development, decentralized journalism platforms are revolutionizing how news is published, verified, and consumed. Gono Moncho, a pioneering platform built on Polygon blockchain, demonstrates how blockchain technology can combat censorship and ensure journalistic integrity.

The platform uses permanent storage on Arweave, ensuring that once published, articles cannot be censored or removed by any single authority. This is particularly crucial for journalists working in oppressive regimes.

Key features include:
- Permanent, immutable storage
- Community-driven verification
- Transparent governance through DAO
- Economic incentives for quality journalism

As we move forward, this technology promises to restore trust in media and protect freedom of speech globally.`,
    author: "Sarah Chen",
    date: "2025-11-25",
    tags: ["blockchain", "journalism", "technology", "decentralization"],
    category: "Technology",
    location: "Global",
    credibilityScore: 95
  },
  {
    title: "Decentralized News Platforms Gain Traction Among Independent Journalists",
    content: `Independent journalists worldwide are increasingly turning to decentralized platforms to publish their work, free from corporate influence and government censorship.

Recent data shows a 300% increase in adoption of blockchain-based journalism platforms over the past year. Reporters cite several key benefits:

1. **Censorship Resistance**: Content stored on Arweave cannot be deleted
2. **Fair Compensation**: Direct rewards from readers without intermediaries  
3. **Verifiable Credentials**: Blockchain-based reputation systems
4. **Community Trust**: Transparent verification processes

"This is the future of journalism," says investigative reporter Maria Rodriguez. "For the first time, we can publish truth without fear of retribution."

The movement represents a fundamental shift in media power dynamics, putting control back in the hands of journalists and readers.`,
    author: "Michael Thompson",
    date: "2025-11-24",
    tags: ["journalism", "decentralization", "freedom of press", "web3"],
    category: "Media",
    location: "International",
    credibilityScore: 92
  },
  {
    title: "Polygon Network Chosen for Major Journalism Platform Launch",
    content: `Gono Moncho, a new decentralized journalism platform, has selected Polygon as its primary blockchain infrastructure, citing scalability and low transaction costs as key factors.

The platform leverages Polygon's Layer 2 solution to provide:
- Near-instant article publication
- Minimal gas fees (under $0.01 per transaction)
- High throughput for global user base
- Environmental sustainability

"Polygon's commitment to scaling Ethereum while maintaining security was crucial for our decision," explained the development team. "Our users need affordable, fast transactions without compromising decentralization."

The platform has already deployed multiple smart contracts on Polygon Amoy testnet, with mainnet launch scheduled for Q1 2026.

Industry analysts predict this could set a precedent for other media platforms seeking blockchain solutions.`,
    author: "David Kumar",
    date: "2025-11-23",
    tags: ["polygon", "blockchain", "infrastructure", "scalability"],
    category: "Technology",
    location: "Global",
    credibilityScore: 88
  },
  {
    title: "How Quadratic Voting is Revolutionizing News Credibility",
    content: `Traditional voting systems in media have long been vulnerable to manipulation and bot attacks. Enter quadratic voting - a mechanism that's changing how we determine news credibility.

Unlike simple one-person-one-vote systems, quadratic voting requires voters to stake tokens based on their conviction. The cost of votes increases quadratically, making manipulation economically infeasible.

Here's how it works:
- 1 vote costs 1 token
- 2 votes cost 4 tokens  
- 3 votes cost 9 tokens
- And so on...

This system ensures that strongly held opinions can be expressed, but spam voting becomes prohibitively expensive.

Early results from Gono Moncho's platform show:
- 95% reduction in bot voting
- More accurate credibility scores
- Increased community engagement
- Better alignment of incentives

"Quadratic voting has transformed our verification process," notes platform governance lead. "The community now has real skin in the game."`,
    author: "Lisa Anderson",
    date: "2025-11-22",
    tags: ["quadratic voting", "governance", "dao", "credibility"],
    category: "Governance",
    location: "Global",
    credibilityScore: 90
  },
  {
    title: "Arweave: The Permanent Web for Journalism",
    content: `In an age where content can disappear at the click of a button, Arweave offers something revolutionary: permanent storage.

Unlike traditional cloud storage or even IPFS, Arweave guarantees that data remains accessible forever through its unique economic model. Journalists are taking notice.

Key Advantages:
- One-time payment for permanent storage
- Cryptographic proof of data integrity
- Censorship-resistant by design
- No recurring fees or renewals

The technology has already preserved:
- 500+ investigative reports
- 10,000+ articles from independent journalists
- Critical evidence of human rights violations
- Historical records from conflict zones

"Arweave ensures our work outlives any attempt to suppress it," explains war correspondent James Wilson. "It's not just storage - it's a guarantee of historical truth."

For journalists worldwide, this represents a paradigm shift in how we preserve and protect information.`,
    author: "Emily Rodriguez",
    date: "2025-11-21",
    tags: ["arweave", "storage", "censorship resistance", "journalism"],
    category: "Technology",
    location: "Global",
    credibilityScore: 94
  }
];

// Function to format for Arweave upload
export function formatForArweave(article: typeof demoArticles[0]) {
  return JSON.stringify(article, null, 2);
}

// Export individual articles for easy copying
export const article1JSON = formatForArweave(demoArticles[0]);
export const article2JSON = formatForArweave(demoArticles[1]);
export const article3JSON = formatForArweave(demoArticles[2]);
export const article4JSON = formatForArweave(demoArticles[3]);
export const article5JSON = formatForArweave(demoArticles[4]);
