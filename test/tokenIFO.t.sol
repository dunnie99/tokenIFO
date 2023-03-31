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
        uint256 supply = 20000000 * 1e18;
        rsqtoken.mint(supply);
        vm.stopPrank();
        
        
    }

    function testcreatePad() public {
        //200000000000000000000000S
        
        uint256 approveAmount = 20000000 * 1e18;
        vm.startPrank(Alice);
        rsqtoken.approve(address(launchpad), approveAmount);
        vm.stopPrank();
        
        vm.startPrank(Alice);
        launchpad.createPad(23, "RASAQ", address(rsqtoken), 2, 1000, approveAmount);
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
        console.log("FUNCTION PASSED");

    }

    // function testincreasePadDuration() public {
    //     testclaimLaunchPad();
    //     vm.stopPrank();
    //     vm.startPrank(Bob);
    //     launchpad.increasePadDuration(23, 3600);

    // }


    function testgetBals() public {
        testclaimLaunchPad();

        launchpad.getBalance();
        launchpad.getTokenBalance(address(rsqtoken));
        console.log("BALANCE PASSED");
        //2000 000 000 000 000 000 000
        vm.stopPrank();


    }



    function testwithdrawal() public {
        testgetBals();

        vm.startPrank(Bob);
        console.log("DUnnnnnnnnie");
        launchpad.transferTokenBal(address(rsqtoken), Idogwu, 19980);
        launchpad.getTokenBalance(address(rsqtoken));
        launchpad.withdraw(Idogwu, 0.001 ether);
        launchpad.getBalance();

        //ether bal => 1 000 000 000 00 000 000;
        //rsqtoken => 1998000;
        //2000 000 000 000 000 000 000;


    }








































































}