// script/Deploy.s.sol
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/tokens/NEWS.sol";
import "../src/tokens/CRED.sol";
import "../src/staking/NewsStaking.sol";
import "../src/governance/libraries/DelegationRegistry.sol";
import "../src/governance/NewsDAO.sol";
import "../src/verification/Verification.sol";
import "../src/external/ArweaveStorage.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        address deployer = msg.sender;

        // Deploy tokens
        NEWS news = new NEWS(deployer);
        CRED cred = new CRED(deployer);

        // Deploy staking
        NewsStaking staking = new NewsStaking(
            address(news),
            address(cred),
            deployer
        );

        // Deploy delegation
        DelegationRegistry delegation = new DelegationRegistry();

        // Deploy DAO
        NewsDAO dao = new NewsDAO(
            address(staking),
            address(cred),
            address(delegation),
            deployer
        );

        // Deploy Arweave storage
        ArweaveStorage arweave = new ArweaveStorage();

        // Deploy verification (mock oracle for now)
        address mockOracle = address(0); // Replace with actual oracle
        Verification verification = new Verification(
            address(cred),
            mockOracle,
            address(arweave)
        );

        // Transfer ownerships
        news.transferOwnership(address(dao));
        cred.transferOwnership(address(dao));
        staking.transferOwnership(address(dao));
        staking.setGovernance(address(dao));

        vm.stopBroadcast();
    }
}
