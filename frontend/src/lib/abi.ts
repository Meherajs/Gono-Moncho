export const gonoMonchoABI = [
  // ... publishArticle, confirmAuthenticity, flagAsMisinformation functions are unchanged ...
  { "type": "function", "name": "publishArticle", "stateMutability": "payable", "inputs": [{ "name": "headline", "type": "string" }, { "name": "content", "type": "string" }], "outputs": [] },
  { "type": "function", "name": "confirmAuthenticity", "stateMutability": "nonpayable", "inputs": [{ "name": "articleId", "type": "uint256" }], "outputs": [] },
  { "type": "function", "name": "flagAsMisinformation", "stateMutability": "nonpayable", "inputs": [{ "name": "articleId", "type": "uint256" }], "outputs": [] },

  // --- NEW READ-ONLY FUNCTIONS FOR ROLE CHECKING ---
  {
    "type": "function",
    "name": "isJournalist",
    "stateMutability": "view", // "view" means it's a read-only function
    "inputs": [{ "name": "user", "type": "address" }],
    "outputs": [{ "name": "", "type": "bool" }]
  },
  {
    "type": "function",
    "name": "isAnalyzer",
    "stateMutability": "view",
    "inputs": [{ "name": "user", "type": "address" }],
    "outputs": [{ "name": "", "type": "bool" }]
  }
] as const;