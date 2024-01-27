//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AppStorage} from "../libraries/LibAppStorage.sol";
import {LibERC20} from "../libraries/LibERC20.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

contract MintFacet {
    AppStorage s;

    IERC20 GLTR_TOKEN 
    
    // 50

    // 
    error MustMintMoreThanOne(uint256 _amount);
    error BadCost(uint256 _cost);
    error CostGreaterThanMaxCost(uint256 _maxTotalCost, uint256 _cost);

    struct MintReceiver {
        address receiver;
        uint256 value;
    }

    function currentPrice() external view returns(uint256 _price) {
        _price = s.totalSupply + 1e18;
    }

    
    // _amountToMint is the whole number of tokens to mint (zero decimals)
    // _cost the whole number of GLTR (zero decimals) that the tokens will cost at current block
    function mintCost(uint256 _amountToMint) external view returns(uint256 cost_) {
        cost_ = internalMintCost(_amountToMint);
    }


    // _amountToMint is the whole number of tokens to mint (zero decimals)
    // _cost the whole number of GLTR (zero decimals) that the tokens will cost at current block
    function internalMintCost(uint256 _amountToMint) internal view returns(uint256 cost_) {
        if(_amountToMint == 0) {
            revert MustMintMoreThanOne(_amountToMint);
        }
        _amountToMint *= 1e18;        
        uint256 last = s.totalSupply;
        uint256 first = last + 1e18;
        last += _amountToMint;
        // Carl Gauss's formula
        // (n / 2)(first number + last number) = sum
        // dividing by 1e36 is the same as dividing by 1e18 twice
        cost_ = ((_amountToMint / 2) * (first + last)) / 1e36;                
    }

    
    // _amountToMint is the whole number of tokens to mint (zero decimals)
    // _maxTotalCost is the whole number of maximum GLTR to pay to mint the tokens (zero decimals)    
    function mint(uint256 _amountToMint, uint256 _maxTotalCost) external returns(uint256 cost_) {        
        cost_ = internalMint(_amountToMint);
        s.totalSupply += _amountToMint * 1e18;
        if(cost_ > _maxTotalCost) {
            revert CostGreaterThanMaxCost(_maxTotalCost, cost);
        }        
    }
    

    function mint(uint256 _cost) external {
        if(_cost == 0) {
            revert BadCost(_cost);
        }
        uint256 first = s.totalSupply + 1;        
        uint256 b = first + first - 1;
        uint256 c = _cost;
        // Apply Quadratic Formula to get the number of tokens to purchase
        // Quadratic Equation form: a * (x * x) + b * x + c = 0 
        // Original quadratic formula: (-b + sqrt(b * b - 4 * a * c)) / ( 2 * a) = amountToMint
        // Because we are not using negative numbers and because the value of a is always one in our use
        // the quadratic formula is modified to apply here.
        // Here is the version of the formula being used:  (sqrt(b * b + 4 * c) - b) /  2 = amountToMint
        // In applying this formula a is 1, b is b and c is c.
        // Formula: (sqrt(b * b - 4 * c) - b) / 2 = n
        uint256 amountToMint = Math.sqrt((b * b + 4 * c) - b) / 2;

        


        uint256 first = s.totalSupply + 1;
        uint256 last = first + _amount - 1;
        // Carl Gauss's formula
        // (n / 2)(first number + last number) = sum
        uint256 cost = ((_amount / 2) * (first + last)) / 1e18;
        if(cost > _maxTotalCost) {
            revert CostGreaterThanMaxCost(_maxTotalCost, cost);
        }
        s.totalSupply = last;      
    }



    // function mintBulk(MintReceiver[] calldata _mintReceivers) external {
    //     LibDiamond.enforceIsContractOwner();
    //     for(uint i; i < _mintReceivers.length; i++) {
    //         MintReceiver calldata mintReceiver = _mintReceivers[i];
    //         require(mintReceiver.receiver != address(0), "_to cannot be zero address");        
    //         s.balances[mintReceiver.receiver] += mintReceiver.value;
    //         s.totalSupply += mintReceiver.value;            
    //         emit LibERC20.Transfer(address(0), mintReceiver.receiver, mintReceiver.value);
    //     }
    // }

    // function mint(address _receiver, uint256 _value) external {
    //     LibDiamond.enforceIsContractOwner();
    //     require(_receiver != address(0), "_to cannot be zero address");        
    //     s.balances[_receiver] += _value;
    //     s.totalSupply += _value;            
    //     emit LibERC20.Transfer(address(0), _receiver, _value);        
    // }


}