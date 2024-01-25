// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/******************************************************************************\
* Author: Nick Mudge
*
/******************************************************************************/

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {IERC20, IERC20Errors} from "../interfaces/IERC20.sol";

library LibERC20 {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    function transfer(AppStorage storage _s, address _from, address _to, uint256 _value) internal {
        if(_from == address(0)) {
            revert IERC20Errors.ERC20InvalidSender(address(0));
        }
        if (_to == address(0)) {
            revert IERC20Errors.ERC20InvalidReceiver(address(0));
        }
        uint256 balance = _s.balances[_from];
        if(balance < _value) {
            revert IERC20Errors.ERC20InsufficientBalance(_from, balance, _value);
        }        
        unchecked {
            _s.balances[_from] -= _value;
            _s.balances[_to] += _value;    
        }        
        emit Transfer(_from, _to, _value);
    }

    function approve(AppStorage storage _s, address _owner, address _spender, uint256 _amount) internal {
        if (_owner == address(0)) {
            revert IERC20Errors.ERC20InvalidApprover(address(0));
        }
        if (_spender == address(0)) {
            revert IERC20Errors.ERC20InvalidSpender(address(0));
        }
        _s.allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }
    
}
