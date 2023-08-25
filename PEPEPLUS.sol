// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@openzeppelin/contracts/utils/math/Math.sol";
import '@openzeppelin/contracts/access/Ownable.sol';


interface IReward{
    function addReward(uint256 amount) external;
}



contract PEPEPLUS is ERC20Burnable, Ownable{
    using SafeMath for uint256;

    uint256 public transferFee = 1;
    uint256 public tokenFee = 1;
    uint256 public lpFee = 2;
    uint256 public burnFee = 1;
    bool public addRewardOpen;
    address public keeper;
    address public _rewardAddress = 0xf955d0af234A957c78Ac612EF6fF9FeBc0F45283;
    address public _ownerAddress;
    address public _lpAddress;
    address public _tokenAddress;
    address public _burnAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => bool) public _isExcludedFromFees;
    mapping(address => bool) public swapAddress;
    event ExcludeFromFees(address indexed account, bool isExcluded);


    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
        _mint(_ownerAddress, 105 * 10**4 * 10**18);
        _isExcludedFromFees[_rewardAddress] = true;
        _isExcludedFromFees[_ownerAddress] = true;
        keeper = msg.sender;
    }
 
    modifier onlyKeeper(){
        require(keeper == msg.sender, "PEPEPLUS:onlyKeeper");
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

        if(takeFee){
            if(swapAddress[from]) {
            uint256 transferAmount = amount.mul(buyFee).div(100);
            amount = amount.sub(transferAmount);  
            super._transfer(from, _rewardAddress, transferAmount);
            }
            if(swapAddress[to]){
            uint256 transferAmount = amount.mul(buyFee).div(100);   
            uint256 tokenAmount = amount.mul(tokenFee).div(100);
            uint256 lpAmount = amount.mul(lpFee).div(100);
            uint256 burnAmount = amount.mul(burnFee).div(100);
            amount = amount.sub(transferAmount).sub(tokenAmount).sub(lpAmount);  
            super._transfer(from, _rewardAddress, transferAmount);
            super._transfer(from, _tokenAddress, tokenAmount);
            super._transfer(from, _lpAddress, lpAmount);
            super._transfer(from, _burnAddress, burnAmount);
            if(addRewardOpen){
                IReward(_tokenAddress).addReward(tokenAmount);
                IReward(_lpAddress).addReward(lpAmount);
            }
            }
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

    function setLpAddress(address addr) external onlyKeeper {
        _LpAddress = addr;
        emit LpAddressSet(addr);
    }

    function setTokenAddress(address addr) external onlyKeeper {
        _tokenAddress = addr;
        emit TokenAddressSet(addr);
    }

    function setSwapAddress(address addr,bool value) external onlyKeeper {
        swapAddress[addr] = value;
        emit SwapAddressSet(addr,value);
    }

    function setAddRewardOpen(bool value) external onlyKeeper {
        addRewardOpen = value;
        emit AddRewardOpenSet(value);
    }

    event RewardAddressSet(address addr);
    event LpAddressSet(address addr);
    event TokenAddressSet(address addr);
    event SwapAddressSet(address addr,bool value);
    event AddRewardOpenSet(bool value);

}
