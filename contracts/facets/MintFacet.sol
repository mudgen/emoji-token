//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AppStorage} from "../libraries/LibAppStorage.sol";
import {LibERC20} from "../libraries/LibERC20.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract MintFacet {
    AppStorage s;

    
    // 50

    // 
    error BadMintAmount(uint256 _amount);
    error CostGreaterThanMaxCost(uint256 _maxTotalCost, uint256 _cost);

    struct MintReceiver {
        address receiver;
        uint256 value;
    }

    function currentPrice() external view returns(uint256 _price) {
        _price = s.totalSupply + 1;
    }

    // Both _amount and _maxTotalCost must have 18 decimal places
    function mint(uint256 _amount, uint256 _maxTotalCost) external {
        if(_amount == 0) {
            revert BadMintAmount(_amount);
        }
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