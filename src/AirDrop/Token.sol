pragma solidity ^0.8.2;

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20Permit{

    constructor() ERC20("Token", "TK"){
        _mint(msg.sender, 1000000 * 10 ** 18);
    }

}