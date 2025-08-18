// test/TokenTest.t.sol
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/tokens/NEWS.sol";
import "../src/tokens/CRED.sol";

contract TokenTest is Test {
    NEWS public news;
    CRED public cred;
    address owner = address(1);
    address user = address(2);

    function setUp() public {
        news = new NEWS(owner);
        cred = new CRED(owner);
    }

    function testNEWSMinting() public {
        vm.prank(owner);
        news.mint(user, 1000);
        assertEq(news.balanceOf(user), 1000);
    }

    function testNEWSBurn() public {
        vm.prank(owner);
        news.mint(user, 1000);

        vm.prank(owner);
        news.burnFrom(user, 500);

        assertEq(news.balanceOf(user), 500);
    }

    function testCREDSoulbound() public {
        vm.prank(owner);
        cred.mint(user, 1000);

        vm.prank(user);
        vm.expectRevert("CRED: Non-transferable soulbound token");
        cred.transfer(address(3), 500);
    }

    function testCREDBurn() public {
        vm.prank(owner);
        cred.mint(user, 1000);

        vm.prank(owner);
        cred.burn(user, 500);

        assertEq(cred.balanceOf(user), 500);
    }

    function testNonOwnerCannotMint() public {
        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user)
        );
        news.mint(user, 1000);

        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user)
        );
        cred.mint(user, 1000);
    }
}
