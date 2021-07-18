// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/******************************************************************************\
* Author: Nick Mudge
*
/******************************************************************************/

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {IERC20} from "../interfaces/IERC20.sol";

library LibERC20 {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    function transfer(AppStorage storage s, address _from, address _to, uint256 _value) internal {
        require(_from != address(0), "_from cannot be zero address");
        require(_to != address(0), "_to cannot be zero address");        
        uint256 balance = s.balances[_from];
        require(balance >= _value, "_value greater than balance");
        unchecked {
            s.balances[_from] -= _value;
            s.balances[_to] += _value;    
        }        
        emit Transfer(_from, _to, _value);
    }

    function approve(AppStorage storage s, address owner, address spender, uint256 amount) internal {        
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");
        s.allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
}
