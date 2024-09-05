pragma solidity ^0.8.2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract AirdropMerkleNFTMarket{
    event Claim(address indexed user, uint256 tokenId);
    
    IERC20 public immutable token;
    IERC721 public immutable nft;
    bytes32 public immutable merkleRoot;

    constructor(IERC20 _token, IERC721 _nft, bytes32 _merkleRoot){
        token = _token;
        nft = _nft;
        merkleRoot = _merkleRoot;
    }

    function permitPrePay(uint256 amount, address approved,  uint8 v, bytes32 r, bytes32 s) external{
        token.permit(msg.sender, address(this), amount, v, r, s);
    }

    function claimNFT(uint256 amount, bytes32[] calldata proof) external{
        bytes32 node = keccak256(abi.encodePacked(msg.sender, amount));
        require(verify(merkleRoot, node, proof), "invalid proof");

        require(token.transferFrom(msg.sender, address(this), amount), "transfer failed");
        nft.mint(msg.sender, amount);
        emit Claim(msg.sender, amount);
    }

    function multicall(bytes[] calldata data) external{
        for(uint256 i = 0; i < data.length; i++){
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success, "multicall failed");
        }
    }
}