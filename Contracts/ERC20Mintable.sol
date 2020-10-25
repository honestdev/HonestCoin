pragma solidity 0.5.12;

import ERC20Burnable.sol;
import MinterRole;

/**
 * @dev Extension of {ERC20} that adds a set of accounts with the {MinterRole},
 * which have permission to mint (create) new tokens as they see fit.
 */
contract ERC20Mintable is ERC20Burnable, MinterRole {

    // if additional minting of tokens is impossible
    bool public mintingFinished;

    // prevent minting of tokens when it is finished.
    // prevent total supply to exceed the limit of emission.
    modifier canMint(uint256 amount) {
        require(amount > 0, "Minting zero amount");
        require(!mintingFinished, "Minting is finished");
        _;
    }

    /**
     * @dev Stop any additional minting of tokens forever.
     * Available only to the owner.
     */
    function finishMinting() external onlyOwner {
        mintingFinished = true;
    }

    /**
     * @dev Minting of new tokens.
     * @param to The address to mint to.
     * @param value The amount to be minted.
     */
    function mint(address to, uint256 value) public onlyMinter canMint(value) returns (bool) {
        _mint(to, value);
        return true;
    }

}
