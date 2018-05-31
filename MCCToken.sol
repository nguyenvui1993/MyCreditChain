pragma solidity ^0.4.21;

import "./token/TransferLimitedToken.sol";

contract MCCToken is TransferLimitedToken {
    // =================================================================================================================
    //                                         Members
    // =================================================================================================================
    string public name = "MyCreditChain";

    string public symbol = "MCC";

    uint8 public decimals = 18;

    // =================================================================================================================
    //                                         Constructor
    // =================================================================================================================

    /**
     * @dev MCC Token
     *      To change to a token for DAICO, you must set up an ITokenEvenListener
     *      to change the voting weight setting through the listener for the
     *      transfer of the token.
     */
    function MCCToken(address _listener, address[] _owners, address _manager) public
        TransferLimitedToken(_listener, _owners, _manager)
    {
        totalSupply_ = uint256(1000000000).mul(uint256(10) ** decimals); // token total supply : 1000000000
        balances[msg.sender] = totalSupply_;
    }

    /**
     * @dev Override ManagedToken.issue. MCCToken can not issue but it need to
     *      distribute tokens to contributors while crowding sales. So. we changed this
     *       Issue tokens to specified wallet
     * @param _to Wallet address
     * @param _value Amount of tokens
     */
    function issue(address _to, uint256 _value) external onlyOwner canIssue {
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        emit Issue(_to, _value);
        emit Transfer(msg.sender, _to, _value);
    }

    /**
     * @dev Destroy tokens on specified address (Called by owner or token holder)
     *      Fund contract address must be in the list of owners to recall token during refund
     * @param _from Wallet address
     * @param _value Amount of tokens to destroy
     */
    function destroy(address _from, uint256 _value) external {
        require(ownerByAddress[msg.sender] || msg.sender == _from);
        require(balances[_from] >= _value);
        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[manager] = SafeMath.add(balances[manager], _value);
        emit Destroy(_from, _value);
    }

    function burn(uint256 _amount) external onlyOwner
    {
        require(_amount <= balances[msg.sender]);

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _amount);
        balances[address(0)] = SafeMath.add(balances[address(0)], _amount);
        Transfer(msg.sender, address(0), _amount);
    }
}
