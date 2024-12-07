// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

abstract contract HasSecondarySaleFees is ERC165 {

    event SecondarySaleFees(uint256 tokenId, address[] recipients, uint[] bps);

    function getFeeRecipients(uint256 id) public view virtual returns (address payable[] memory);
    function getFeeBps(uint256 id) public view virtual returns (uint[] memory);

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return
            interfaceId == this.getFeeRecipients.selector ||
            interfaceId == this.getFeeBps.selector ||
            super.supportsInterface(interfaceId);
    }
}