//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import {AppStorage} from "../libraries/LibAppStorage.sol";
import {LibERC20} from "../libraries/LibERC20.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract MintFacet {
    AppStorage s;

    struct MintReceiver {
        address receiver;
        uint256 value;
    }

    function mintBulk(MintReceiver[] calldata _mintReceivers) external {
        LibDiamond.enforceIsContractOwner();
        for(uint i; i < _mintReceivers.length; i++) {
            MintReceiver calldata mintReceiver = _mintReceivers[i];
            require(mintReceiver.receiver != address(0), "_to cannot be zero address");        
            s.balances[mintReceiver.receiver] += mintReceiver.value;
            s.totalSupply += mintReceiver.value;            
            emit LibERC20.Transfer(address(0), mintReceiver.receiver, mintReceiver.value);
        }
    }

    function mint(address _receiver, uint256 _value) external {
        LibDiamond.enforceIsContractOwner();
        require(_receiver != address(0), "_to cannot be zero address");        
        s.balances[_receiver] += _value;
        s.totalSupply += _value;            
        emit LibERC20.Transfer(address(0), _receiver, _value);        
    }


}