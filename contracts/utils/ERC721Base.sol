// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./HasSecondarySaleFees.sol";

/**
 * @title Full ERC721 Token with support for tokenURIPrefix
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */

contract ERC721Base is ERC721Enumerable, ERC721URIStorage, HasSecondarySaleFees {

    struct Fee {
        address payable recipient;
        uint256 value;
    }

    // id => fees
    mapping (uint256 => Fee[]) public fees;

    /**
     * @dev Constructor function
     */
    constructor (string memory _name, string memory _symbol) ERC721(_name, _symbol)  {        
    }

    function getFeeRecipients(uint256 id) public view override returns (address payable[] memory) {
        Fee[] memory _fees = fees[id];
        address payable[] memory result = new address payable[](_fees.length);
        for (uint i = 0; i < _fees.length; i++) {
            result[i] = _fees[i].recipient;
        }
        return result;
    }

    function getFeeBps(uint256 id) public view override returns (uint[] memory) {
        Fee[] memory _fees = fees[id];
        uint[] memory result = new uint[](_fees.length);
        for (uint i = 0; i < _fees.length; i++) {
            result[i] = _fees[i].value;
        }
        return result;
    }

    function _mint(address to, uint256 tokenId, Fee[] memory _fees) internal {
        _mint(to, tokenId);
        address[] memory recipients = new address[](_fees.length);
        uint[] memory bps = new uint[](_fees.length);
        for (uint i = 0; i < _fees.length; i++) {
            require(_fees[i].recipient != address(0x0), "Recipient  be present");
            require(_fees[i].value != 0, "Fee value  be positive");
            fees[tokenId].push(_fees[i]);
            recipients[i] = _fees[i].recipient;
            bps[i] = _fees[i].value;
        }
        if (_fees.length > 0) {
            emit SecondarySaleFees(tokenId, recipients, bps);
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, ERC721URIStorage, HasSecondarySaleFees) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * See {ERC721-_increaseBalance}. We need that to account tokens that were minted in batch
     */
    function _increaseBalance(address account, uint128 amount) internal virtual override(ERC721Enumerable, ERC721) {
        ERC721Enumerable._increaseBalance(account, amount);
    }

    /**
     * @dev See {ERC721-_update}.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual override(ERC721Enumerable, ERC721) returns (address) {
        return ERC721Enumerable._update(to, tokenId, auth);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }
}