// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/verification/ReporterRegistry.sol";
import "../src/tokens/NEWS.sol";

contract DeployReporterRegistryScript is Script {
    function run() external {
        // Load private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deployer address:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // Use existing NEWS token address from Polygon Amoy
        address newsTokenAddress = 0xd3091433da9a925c38682b28ffbae975ed06617a;

        console.log("Deploying ReporterRegistry...");
        console.log("NEWS Token:", newsTokenAddress);

        // Deploy ReporterRegistry
        ReporterRegistry reporterRegistry = new ReporterRegistry(
            newsTokenAddress,
            deployer // initial owner
        );

        console.log("ReporterRegistry deployed at:", address(reporterRegistry));
        console.log("Testing mode enabled:", reporterRegistry.testingMode());

        vm.stopBroadcast();
    }
}
