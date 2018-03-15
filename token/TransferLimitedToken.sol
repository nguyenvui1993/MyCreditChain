pragma solidity ^0.4.18;

import './ManagedToken.sol';

/**
 * @title TransferLimitedToken
 * @dev Token with ability to limit transfers within wallets included in limitedWallets list for certain period of time
 */
contract TransferLimitedToken is ManagedToken {

    mapping(address => bool) public limitedWallets;
    address public limitedWalletsManager;
    bool public isLimitEnabled;

    modifier onlyManager() {
        require(msg.sender == limitedWalletsManager);
        _;
    }

    /**
     * @dev Check if transfer between addresses is available
     * @param _from From address
     * @param _to To address
     */
    modifier canTransfer(address _from, address _to)  {
        require(!isLimitEnabled || (!limitedWallets[_from] && !limitedWallets[_to]));
        _;
    }

    /**
     * @dev TransferLimitedToken constructor
     * @param _listener Token listener(address can be 0x0)
     * @param _owners Owners list
     * @param _limitedWalletsManager Address used to add/del wallets from limitedWallets
     */
    function TransferLimitedToken(address _listener, address[] _owners, address _limitedWalletsManager) public
        ManagedToken(_listener, _owners)
    {
        isLimitEnabled = true;
        limitedWalletsManager = _limitedWalletsManager;
    }

    /**
     * @dev Add address to limitedWallets
     * @dev Can be called only by manager
     */
    function addLimitedWalletAddress(address _wallet) public onlyManager {
        limitedWallets[_wallet] = true;
    }

    /**
     * @dev Del address from limitedWallets
     * @dev Can be called only by manager
     */
    function delLimitedWalletAddress(address _wallet) public onlyManager {
        limitedWallets[_wallet] = false;
    }

    function isLimitedWalletAddress(address _wallet) public view returns(bool) {
        return limitedWallets[_wallet];
    }

    /**
     * @dev Disable transfer limit manually. Can be called only by manager
     */
    function disableLimit() public onlyManager {
        isLimitEnabled = false;
    }

    function transfer(address _to, uint256 _value) public canTransfer(msg.sender, _to) returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public canTransfer(_from, _to) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public canTransfer(msg.sender, _spender) returns (bool) {
        return super.approve(_spender,_value);
    }
}