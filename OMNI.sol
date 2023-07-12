// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@openzeppelin/contracts/utils/math/Math.sol";
import '@openzeppelin/contracts/access/Ownable.sol';



contract OMNI is ERC20Burnable, Ownable{
    using SafeMath for uint256;

    uint256 public transferFee = 1;
    address public keeper;
    // address public _rewardAddress = 0x6704dB7A0F22C0d0452def8d698F7Dd2BA95930E;
    // address public _ownerAddress = 0x5f7d15eb9506098ed2CFa846551393Fa46611FA4;
    address public _rewardAddress = 0xf955d0af234A957c78Ac612EF6fF9FeBc0F45283;
    address public _ownerAddress = 0xE37E2d96c3Cc7C95ca8E99619C71B7F3e92444a6;
    mapping(address => bool) public _isExcludedFromFees;
    mapping(address => bool) public swapAddress;
    event ExcludeFromFees(address indexed account, bool isExcluded);


    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
        _mint(_ownerAddress, 2100 * 10**4 * 10**18);
        _isExcludedFromFees[_rewardAddress] = true;
        _isExcludedFromFees[_ownerAddress] = true;
        keeper = msg.sender;
    }
 
    modifier onlyKeeper(){
        require(keeper == msg.sender, "OMNI:onlyKeeper");
        _;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        bool takeFee = true;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        else if(swapAddress[from]||swapAddress[to]) {
            if(swapAddress[from]){
            takeFee = false;
            }
            uint256 transferAmount = amount.mul(transferFee).div(100); 
            amount = amount.sub(transferAmount);      
            super._transfer(from, _rewardAddress, transferAmount);
        }

        if (takeFee) {
            amount = amount.mul(99).div(100);   
        }  
        super._transfer(from, to, amount);
        return;

    }

    function excludeFromFees(address account, bool excluded) public onlyKeeper {
        require(
            _isExcludedFromFees[account] != excluded,
            "ALM: Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }


    function setRewardAddress(address addr) external onlyKeeper {
        _rewardAddress = addr;
        emit RewardAddressSet(addr);
    }

    function setSwapAddress(address addr,bool value) external onlyKeeper {
        swapAddress[addr] = value;
        emit SwapAddressSet(addr,value);
    }

    event RewardAddressSet(address addr);
    event SwapAddressSet(address addr,bool value);

}
