pragma solidity 0.5.12;

import ERC20Mintable.sol;
import ERC20Detailed;
import ApproveAndCallFallBack;

/**
 * @title The main project contract.
 */
contract HonestCoinToken is ERC20Mintable, ERC20Detailed {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // registered contracts (to prevent loss of token via transfer function)
    mapping (address => bool) private _contracts;

    constructor(address initialOwner, address recipient) public ERC20Detailed("HonestCoin", "USDH", 6) Ownable(initialOwner) {
        // creating of inital supply
        uint256 INITIAL_SUPPLY = 88888888e6;
        _mint(recipient, INITIAL_SUPPLY);
    }

    /**
     * @dev modified transfer function that allows to safely send tokens to smart-contract.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {

        if (_contracts[to]) {
            approveAndCall(to, value, new bytes(0));
        } else {
            super.transfer(to, value);
        }

        return true;

    }

    /**
    * @dev Allows to send tokens (via Approve and TransferFrom) to other smart-contract.
    * @param spender Address of smart contracts to work with.
    * @param amount Amount of tokens to send.
    * @param extraData Any extra data.
    */
    function approveAndCall(address spender, uint256 amount, bytes memory extraData) public returns (bool) {
        require(approve(spender, amount));

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, amount, address(this), extraData);

        return true;
    }

    /**
     * @dev Allows to register other smart-contracts (to prevent loss of tokens via transfer function).
     * @param account Address of smart contracts to work with.
     */
    function registerContract(address account) external onlyOwner {
        require(_isContract(account), "Token: account is not a smart-contract");
        _contracts[account] = true;
    }

    /**
     * @dev Allows to unregister registered smart-contracts.
     * @param account Address of smart contracts to work with.
     */
    function unregisterContract(address account) external onlyOwner {
        require(isRegistered(account), "Token: account is not registered yet");
        _contracts[account] = false;
    }

    /**
    * @dev Allows to any owner of the contract withdraw needed ERC20 token from this contract (for example promo or bounties).
    * @param ERC20Token Address of ERC20 token.
    * @param recipient Account to receive tokens.
    */
    function withdrawERC20(address ERC20Token, address recipient) external onlyOwner {

        uint256 amount = IERC20(ERC20Token).balanceOf(address(this));
        IERC20(ERC20Token).safeTransfer(recipient, amount);

    }

    /**
     * @return true if the address is registered as contract
     * @param account Address to be checked.
     */
    function isRegistered(address account) public view returns (bool) {
        return _contracts[account];
    }

    /**
     * @return true if `account` is a contract.
     * @param account Address to be checked.
     */
    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

}
