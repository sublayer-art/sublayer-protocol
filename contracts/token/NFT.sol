// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/SignerRole.sol";
import "../utils/ERC721Base.sol";

/**
 * @title NFT721
 * @dev anyone can mint token.
 */
contract NFT721 is Ownable, SignerRole, IERC721, ERC721Base {

    constructor (string memory name, string memory symbol, address signer) ERC721Base(name, symbol) Ownable(msg.sender) {
        _addSigner(signer);
        // transferOwnership(newOwner);
    }

    function addSigner(address account) public override onlyOwner {
        _addSigner(account);
    }

    function removeSigner(address account) public onlyOwner {
        _removeSigner(account);
    }

    function mint(uint256 tokenId, uint8 v, bytes32 r, bytes32 s, Fee[] memory _fees, string memory tokenURI) public {
        require(isSigner(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(this, tokenId)))), v, r, s)), "owner should sign tokenId");
        _mint(msg.sender, tokenId, _fees);
        _setTokenURI(tokenId, tokenURI);
    }
}