// SPDX-License-Identifier: MIT
// Code modified from 
pragma solidity 0.8.23;
// Code modified from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/extensions/ERC20Permit.sol
import { AppStorage } from "../libraries/LibAppStorage.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { LibERC20 } from "../libraries/LibERC20.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 */
contract ERC20PermitFacet {
    AppStorage s;
    
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable CACHED_CHAIN_ID;
    
    bytes32 private immutable HASHED_NAME;
    bytes32 private immutable HASHED_VERSION;


    // should be the proxy address
    address private immutable CACHED_THIS;
    
     
    bytes32 private constant TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Permit deadline has expired.
     */
    error ERC2612ExpiredSignature(uint256 deadline);

    /**
     * @dev Mismatched signature.
     */
    error ERC2612InvalidSigner(address signer, address owner);

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    // constructor(string memory name) EIP712(name, "1") {}
    constructor(address _diamondAddress) {                
        HASHED_NAME = keccak256(bytes(unicode"💎 Token"));
        HASHED_VERSION = keccak256(bytes("1"));
        CACHED_CHAIN_ID = block.chainid;
        CACHED_DOMAIN_SEPARATOR = buildDomainSeparator(_diamondAddress);
        CACHED_THIS = _diamondAddress;
    }

    
    /**
     * @dev Returns the domain separator for the current chain.
     */
    function domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == CACHED_THIS && block.chainid == CACHED_CHAIN_ID) {
            return CACHED_DOMAIN_SEPARATOR;
        } else {
            return buildDomainSeparator(address(this));
        }
    }

    function buildDomainSeparator(address _diamondAddress) private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, HASHED_NAME, HASHED_VERSION, block.chainid, _diamondAddress));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function hashTypedDataV4(bytes32 _structHash) internal view virtual returns (bytes32) {
        return  MessageHashUtils.toTypedDataHash(domainSeparatorV4(), _structHash);
    }

     function eip712Domain()
        external
        view        
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            unicode"💎 Token",
            "1",
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        if (block.timestamp > _deadline) {
          revert ERC2612ExpiredSignature(_deadline);
        }
        
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, _owner, _spender, _value, useNonce(_owner), _deadline));

        bytes32 hash = hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, _v, _r, _s);
        if (signer != _owner) {
          revert ERC2612InvalidSigner(signer, _owner);
        }        

        LibERC20.approve(s, _owner, _spender, _value);
    }

    function nonces(address _owner) external view returns (uint256) {
        return s.nonces[_owner];
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return domainSeparatorV4();
    }

    function useNonce(address _owner) internal returns (uint256 current_) {        
        current_ = s.nonces[_owner];
        s.nonces[_owner] = current_ + 1;
    }
}
