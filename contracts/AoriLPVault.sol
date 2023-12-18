// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { IAoriProtocol } from "aori-contracts/src/IAoriProtocol.sol";
import { AoriProtocol } from "aori-contracts/src/AoriProtocol.sol";
import { FlashExecutor } from "./FlashExecutor.sol";
import { IERC1271 } from "openzeppelin-contracts/contracts/interfaces/IERC1271.sol";
import { IERC4626 } from "forge-std/interfaces/IERC4626.sol";

contract AoriLpVault is IERC1271, FlashExecutor, IERC4626 {

    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 constant internal ERC1271_MAGICVALUE = 0x1626ba7e;
    
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    mapping(address account => uint256) private balances;

    mapping(address account => mapping(address spender => uint256)) private allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    address public _aoriProtocol;

    // ERC-4626
    address public assetTokenAddress;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _owner,
        address aoriProtocol_,
        address _balancerAddress,
        address assetTokenAddress_,
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) FlashExecutor(_owner, _balancerAddress) {
        _aoriProtocol = aoriProtocol_;
        assetTokenAddress = assetTokenAddress_;
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;
    }

    /*//////////////////////////////////////////////////////////////
                                ERC-4626
    //////////////////////////////////////////////////////////////*/

    function asset() external view returns (address) {
        return assetTokenAddress;
    }

    function totalAssets() external view returns (uint256) {
        return 0; // TODO:
    }

    function convertToShares(uint256 _assets) external view returns (uint256) {
        return 0; // TODO:
    }

    function convertToAssets(uint256 _shares) external view returns (uint256) {
        return 0; // TODO:
    }

    function maxDeposit(address _receiver) external view returns (uint256) {
        return 0; // TODO:
    }

    function previewDeposit(uint256 _assets) external view returns (uint256) {
        return 0; // TODO:
    }

    function deposit(uint256 _assets, address _receiver) external returns (uint256) {
        return 0; // TODO:
    }

    function maxMint(address _receiver) external view returns (uint256) {
        return 0; // TODO:
    }

    function previewMint(uint256 _shares) external view returns (uint256) {
        return 0; // TODO:
    }

    function mint(uint256 _shares, address _receiver) external returns (uint256) {
        return 0; // TODO:
    }

    function maxWithdraw(address _owner) external view returns (uint256) {
        return 0; // TODO:
    }

    function previewWithdraw(uint256 _shares) external view returns (uint256) {
        return 0; // TODO:
    }

    function withdraw(uint256 _shares, address _receiver, address _owner) external returns (uint256) {
        return 0; // TODO:
    }

    function maxRedeem(address _owner) external view returns (uint256) {
        return 0; // TODO:
    }

    function previewRedeem(uint256 _shares) external view returns (uint256) {
        return 0; // TODO:
    }

    function redeem(uint256 _shares, address _receiver, address _owner) external returns (uint256) {
        return 0; // TODO:
    }

    /*//////////////////////////////////////////////////////////////
                                 ERC-20
    //////////////////////////////////////////////////////////////*/

    // function allowance(address _owner, address _spender) external view returns (uint256) {
    //     return 0; // TODO:
    // }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal virtual {
        if (owner == address(0)) {
            revert();
        }
        if (spender == address(0)) {
            revert();
        }
        allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return balances[account];
    }

    function decimals() external view returns (uint8) {
        return 18;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        return false; // TODO:
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) {
        return false; // TODO:
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return allowances[owner][spender];
    }

    /*//////////////////////////////////////////////////////////////
                                EIP-1271
    //////////////////////////////////////////////////////////////*/

    function isValidSignature(bytes32 _hash, bytes memory _signature) public view returns (bytes4) {
        require(_signature.length == 65);

        // Deconstruct the signature into v, r, s
        uint8 v;
        bytes32 r;
        bytes32 s;
        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(_signature, 32))
            // second 32 bytes.
            s := mload(add(_signature, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(_signature, 96)))
        }

        address ethSignSigner = ecrecover(_hash, v, r, s);

        // EIP1271 - dangerous if the eip151-eip1271 pairing can be found
        address eip1271Signer = ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _hash
                )
            ), v, r, s);

        // check if the signature comes from a valid manager
        if (managers[ethSignSigner] || managers[eip1271Signer]) {
            return ERC1271_MAGICVALUE;
        }

        return 0x0;
    }
}