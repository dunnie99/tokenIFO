// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/tokenIFO.sol";
import "../src/mockToken.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract tokenIFOTest is Test {

    launchPadIFO public launchpad;
    RSQtoken public rsqtoken;


    address Bob = vm.addr(0x1);
    address Alice = vm.addr(0x2);
    address Idogwu = vm.addr(0x3);
    address Faith = vm.addr(0x4);
    address Femi = vm.addr(0x5);
    address Nonso = vm.addr(0x6);

    uint price = 1000;


    function setUp() public {
        vm.prank(Bob);
        launchpad = new launchPadIFO();
        ///////////////////////////////////////////
        vm.startPrank(Alice);
        rsqtoken = new RSQtoken("RASAQ", "RSQ");
        rsqtoken.mint(2000000000);
        
        
    }

    function testcreatePad() public {
        rsqtoken.approve(address(launchpad), 2000000);
        //uint256 supply = (2/0.001) * 1000;
        //if(supply == 2000000) revert("Good girl, love you!");
        launchpad.createPad(23, "RASAQ", address(rsqtoken), 2, 100, 2000000);
        vm.stopPrank();
    }

    function testlaunchPad() public{
        testcreatePad();
        vm.prank(Bob);
        launchpad.launchPad(23, "RASAQ");
        vm.startPrank(Faith);
        vm.deal(Faith, 1000 ether);
    }

    function teststakeOnPad() public {
        testlaunchPad();
        launchpad.stakeOnPad{ value: 1 ether}(23, "RASAQ");
    }

    function testclaimLaunchPad() public {
        teststakeOnPad();
        vm.warp(10800);//3hrs.
        // vm.stopPrank();
        // vm.prank(Idogwu);
        launchpad.claimLaunchPad(23, "RASAQ");

    }







































































}