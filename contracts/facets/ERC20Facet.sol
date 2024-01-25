//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AppStorage} from "../libraries/LibAppStorage.sol";
import {LibERC20} from "../libraries/LibERC20.sol";
import {IERC20Errors} from "../interfaces/IERC20.sol";


contract ERC20Facet {
    AppStorage s;
    
    function name() external pure returns (string memory)  {
        return unicode"💎 Token";
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
        if(currentAllowance < _value) {
            revert IERC20Errors.ERC20InsufficientAllowance(msg.sender, currentAllowance, _value);
        }
        unchecked {
            LibERC20.approve(s, _from, msg.sender, currentAllowance - _value);        
        }             
        return true;        
    }
}
