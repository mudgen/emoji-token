// SPDX-License-Identifier: MIT
// Code modified from 
pragma solidity 0.8.6;
// Code modified from https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC20/extensions/draft-ERC20Permit.sol
import { AppStorage } from "../libraries/LibAppStorage.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";
import { LibERC20 } from "../libraries/LibERC20.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
contract ERC20PermitFacet {
    AppStorage s;
    using Counters for Counters.Counter;

    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable CACHED_CHAIN_ID;

    bytes32 private immutable HASHED_NAME;
    bytes32 private immutable HASHED_VERSION;
    bytes32 private immutable TYPE_HASH;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    // constructor(string memory name) EIP712(name, "1") {}
    constructor() {
        bytes32 hashedName = keccak256(bytes("Diamond Emoji Token"));
        bytes32 hashedVersion = keccak256(bytes("1"));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        HASHED_NAME = hashedName;
        HASHED_VERSION = hashedVersion;
        CACHED_CHAIN_ID = block.chainid;
        CACHED_DOMAIN_SEPARATOR = buildDomainSeparator(typeHash, hashedName, hashedVersion);
        TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == CACHED_CHAIN_ID) {
            return CACHED_DOMAIN_SEPARATOR;
        } else {
            return buildDomainSeparator(TYPE_HASH, HASHED_NAME, HASHED_VERSION);
        }
    }

    function buildDomainSeparator(
        bytes32 _typeHash,
        bytes32 _nameHash,
        bytes32 _versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(_typeHash, _nameHash, _versionHash, block.chainid, address(this)));
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
        return ECDSA.toTypedDataHash(domainSeparatorV4(), _structHash);
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
        require(block.timestamp <= _deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, _owner, _spender, _value, useNonce(_owner), _deadline));

        bytes32 hash = hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, _v, _r, _s);
        require(signer == _owner, "ERC20Permit: invalid signature");

        LibERC20.approve(s, _owner, _spender, _value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address _owner) public view returns (uint256) {
        return s.nonces[_owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function useNonce(address _owner) internal returns (uint256 current) {
        Counters.Counter storage nonce = s.nonces[_owner];
        current = nonce.current();
        nonce.increment();
    }
}
