//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import {AppStorage} from "../libraries/LibAppStorage.sol";
import {LibERC20} from "../libraries/LibERC20.sol";


contract ERC20Facet {
    AppStorage s;
    
    function name() external pure returns (string memory)  {
        return unicode"Diamond Emoji Token";
    }

    function symbol() external pure returns (string memory) {
        return unicode"💎";
    }

    function decimals() external pure returns (uint8) { 
        return 18;        
    }

    function totalSupply() external view returns (uint256) {
        return s.totalSupply;
    }

    function balanceOf(address _owner) external view returns (uint256 balance_) {
        balance_ = s.balances[_owner];
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        LibERC20.approve(s, msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) external returns (bool) {
        unchecked {
            LibERC20.approve(s, msg.sender, _spender, s.allowances[msg.sender][_spender] + _addedValue);
        }
        return true;
    }      

    function decreaseAllowance(address _spender, uint256 _subtractedValue) external returns (bool) {
        uint256 currentAllowance = s.allowances[msg.sender][_spender];
        require(currentAllowance >= _subtractedValue, "Cannot decrease allowance to less than 0");
        unchecked {
         LibERC20.approve(s, msg.sender, _spender, currentAllowance - _subtractedValue);   
        }        
        return true;        
    }

    function allowance(address _owner, address _spender) external view returns (uint256 remaining_) {
        return s.allowances[_owner][_spender];
    }    

    function transfer(address _to, uint256 _value) external returns (bool) {        
        LibERC20.transfer(s, msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        LibERC20.transfer(s, _from, _to, _value);
        uint256 currentAllowance = s.allowances[_from][msg.sender];
        require(currentAllowance >= _value, "transfer amount exceeds allowance");
        unchecked {
            LibERC20.approve(s, _from, msg.sender, currentAllowance - _value);        
        }             
        return true;        
    }

}
