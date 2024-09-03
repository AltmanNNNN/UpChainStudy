pragma solidity ^0.8.2;

contract RNT is ERC20Permit{

    constructor() ERC20Permit("RNT", "RNT") ERC20("RNT", "RNT"){
        _mint(msg.sender, 21000000 * 10 ** decimals());
    }
}