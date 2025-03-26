// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IAllowanceTransfer} from "../interfaces/IAllowanceTransfer.sol";

contract EIP712Signature {
    using ECDSA for bytes32;
    
    // Domain Separator components
    bytes32 public constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
    
    bytes32 public immutable DOMAIN_SEPARATOR = 0x3b6f35e4fce979ef8eac3bcdc8c3fc38fe7911bb0c69c8fe72bf1fd1a17e6f07;

    // PermitDetails and PermitSingle typehash
    bytes32 private constant PERMIT_DETAILS_TYPEHASH = keccak256(
        "PermitDetails(address token,uint160 amount,uint48 expiration,uint48 nonce)"
    );

    bytes32 private constant PERMIT_SINGLE_TYPEHASH = keccak256(
        "PermitSingle(PermitDetails details,address spender,uint256 sigDeadline)PermitDetails(address token,uint160 amount,uint48 expiration,uint48 nonce)"
    );
    
    mapping(address => uint256) public nonces;
    
    // constructor(string memory name, string memory version) {
    //     DOMAIN_SEPARATOR = keccak256(
    //         abi.encode(
    //             EIP712DOMAIN_TYPEHASH,
    //             keccak256(bytes(name)),
    //             keccak256(bytes(version)),
    //             block.chainid,
    //             address(this)
    //         )
    //     );
    // }

    // Hash a PermitDetails struct according to EIP-712
    function hashPermitDetails(IAllowanceTransfer.PermitDetails memory details) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                PERMIT_DETAILS_TYPEHASH,
                details.token,
                details.amount,
                details.expiration,
                details.nonce
            )
        );
    }

    // Hash a PermitSingle struct according to EIP-712
    function hashPermitSingle(IAllowanceTransfer.PermitSingle memory permitSingle) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                PERMIT_SINGLE_TYPEHASH,
                hashPermitDetails(permitSingle.details),
                permitSingle.spender,
                permitSingle.sigDeadline
            )
        );
    }

    // Generate the digest that gets signed for a PermitSingle struct
    function getPermitSingleDigest(IAllowanceTransfer.PermitSingle memory permitSingle) public pure returns (bytes32) {
        bytes32 structHash = hashPermitSingle(permitSingle);
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                structHash
            )
        );
    }

    // Verify a signature for a PermitSingle struct
    function verifyPermitSingle(
        IAllowanceTransfer.PermitSingle memory permitSingle,
        address owner,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (bool) {
        bytes32 digest = getPermitSingleDigest(permitSingle);
        address signer = ecrecover(digest, v, r, s);
        return signer != address(0) && signer == owner;
    }

    // Alternative verify using signature bytes for a PermitSingle
    function verifyPermitSingleSignature(
        IAllowanceTransfer.PermitSingle memory permitSingle,
        address owner,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 digest = getPermitSingleDigest(permitSingle);
        address signer = digest.recover(signature);
        return signer != address(0) && signer == owner;
    }
}