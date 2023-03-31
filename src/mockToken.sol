// SPDX-License-Identifier: MIT


pragma solidity 0.8.17;


import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract W3BVIII is ERC20 {
    address owner;
    string _name;
    string _symbol;
    mapping(address => uint256) amountMinted;

    constructor(string memory name, string memory symbol) ERC20(name,symbol){
        _name = name;
        _symbol = symbol;
        owner = msg.sender;

        
//3 000 000 000 000 000 000

    }



    function mint(uint amount) public {
        require(msg.sender == owner, "Not owner");
        _mint(owner, amount * 10**decimals());
        amountMinted[msg.sender] = amount;
    }

}