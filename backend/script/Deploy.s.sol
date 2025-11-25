// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/tokens/NEWS.sol";
import "../src/tokens/CRED.sol";
import "../src/staking/NewsStaking.sol";
import "../src/governance/libraries/DelegationRegistry.sol";
import "../src/governance/NewsDAO.sol";
import "../src/verification/Verification.sol";
import "../src/verification/ReporterRegistry.sol";
import "../src/external/ArweaveStorage.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deploying with address:", deployer);

        // Deploy tokens
        console.log("Deploying NEWS token...");
        NEWS news = new NEWS(deployer);
        console.log("NEWS deployed at:", address(news));
        console.log("NEWS deployed at:", address(news));

        console.log("Deploying CRED token...");
        CRED cred = new CRED(deployer);
        console.log("CRED deployed at:", address(cred));

        // Deploy staking
        console.log("Deploying NewsStaking...");
        NewsStaking staking = new NewsStaking(
            address(news),
            address(cred),
            deployer
        );
        console.log("NewsStaking deployed at:", address(staking));

        // Deploy delegation
        console.log("Deploying DelegationRegistry...");
        DelegationRegistry delegation = new DelegationRegistry();
        console.log("DelegationRegistry deployed at:", address(delegation));

        // Deploy DAO
        console.log("Deploying NewsDAO...");
        NewsDAO dao = new NewsDAO(
            address(staking),
            address(cred),
            address(delegation),
            deployer
        );
        console.log("NewsDAO deployed at:", address(dao));

        // Deploy Arweave storage
        console.log("Deploying ArweaveStorage...");
        ArweaveStorage arweave = new ArweaveStorage();
        console.log("ArweaveStorage deployed at:", address(arweave));

        // Deploy Reporter Registry
        console.log("Deploying ReporterRegistry...");
        ReporterRegistry reporterRegistry = new ReporterRegistry(
            address(news),
            deployer
        );
        console.log("ReporterRegistry deployed at:", address(reporterRegistry));

        // Deploy verification (mock oracle for now)
        console.log("Deploying Verification...");
        address mockOracle = address(0); // Replace with actual oracle
        Verification verification = new Verification(
            address(cred),
            mockOracle,
            address(arweave),
            address(reporterRegistry)
        );
        console.log("Verification deployed at:", address(verification));

        // Transfer ownerships
        console.log("Transferring ownerships to DAO...");
        news.transferOwnership(address(dao));
        cred.transferOwnership(address(dao));

        // Set governance BEFORE transferring staking ownership
        staking.setGovernance(address(dao));
        staking.transferOwnership(address(dao));

        vm.stopBroadcast();

        // Log deployment summary
        console.log("\n=== Deployment Complete ===");
        console.log("NEWS:", address(news));
        console.log("CRED:", address(cred));
        console.log("NewsStaking:", address(staking));
        console.log("NewsDAO:", address(dao));
        console.log("Verification:", address(verification));
        console.log("ReporterRegistry:", address(reporterRegistry));
        console.log("ArweaveStorage:", address(arweave));
        console.log("DelegationRegistry:", address(delegation));
    }
}
