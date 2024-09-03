pragma solidity ^0.8.2;

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RNT is ERC20Permit{
    constructor() ERC20Permit("RNT") ERC20("RNT", "RNT") {
        _mint(msg.sender, 21000000 * 10 ** decimals());
    }
}