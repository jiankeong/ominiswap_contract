// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../owner/AdminRole.sol";

interface IONFT {
    function getType(uint256 tokenId) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface IStakePool {
    function stakePower(address addr,uint256 amount) external;
    function stake(uint256 amount) external;
}


contract PEPENFTPool is AdminRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    IERC20 public PEPE;
    address public omni = 0x8cE12F697088746a260ec8990dbDE7A40a0a9b7C;
    address public onft;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public stakePool;
    uint256 public totalReward;
    uint256 public starttime; // starttime TBD
    mapping(uint256 => uint256) public nftReward;
    mapping(uint256 => uint256) public activeAmount;
    mapping(uint256 => uint256) public nftPower;
    mapping(uint256 => bool) public activeStats;
    mapping(uint256 => uint256) public claimedReward;

    constructor(
        address pepe_,
        address nft_,
        uint256 starttime_
    ) {
        PEPE = IERC20(pepe_);
        onft = nft_;
        starttime = starttime_;
        nftPower[1] = 100;
        nftPower[2] = 500;
        nftPower[3] = 1000;
        nftPower[4] = 5000;
        nftPower[5] = 10000;
        nftPower[6] = 50000;
        nftPower[7] = 100000;
        activeAmount[1] = 10;
        activeAmount[2] = 50;
        activeAmount[3] = 100;
        activeAmount[4] = 500;
        activeAmount[5] = 1000;
        activeAmount[6] = 5000;
        activeAmount[7] = 10000;
    }

    modifier checkStart() {
        require(block.timestamp >= starttime, "not start");
        _;
    }

    function updateStartTime(uint256 starttime_) external onlyAdmin {
        starttime = starttime_;
    }

    function addReward(uint256 reward)
        external
        onlyAdmin
    {
        totalReward += reward;
        nftReward[1] = totalReward * 100/26800000;
        nftReward[2] = totalReward * 500/26800000;
        nftReward[3] = totalReward * 1000/26800000;
        nftReward[4] = totalReward * 5000/26800000;
        nftReward[5] = totalReward * 10000/26800000;
        nftReward[6] = totalReward * 50000/26800000;
        nftReward[7] = totalReward * 100000/26800000;
    }

    function getReward(uint256 tokenId) public  checkStart {
        uint256 lvl = IONFT(onft).getType(tokenId);
        address addr = IONFT(onft).ownerOf(tokenId);
        require(addr == msg.sender,"NFT OWNERSHIP ERROR");
        uint256 reward = nftReward[lvl] - claimedReward[tokenId];
        if (reward > 0) {
            PEPE.safeTransfer(msg.sender, reward);
            claimedReward[tokenId] = nftReward[lvl];
        }
    }

    function active(uint256 tokenId) public  checkStart {
        uint256 lvl = IONFT(onft).getType(tokenId);
        address addr = IONFT(onft).ownerOf(tokenId);
        require(addr == msg.sender,"NFT OWNERSHIP ERROR");
        require(!activeStats[tokenId],"ACTIVE ALREADY");
        IERC20(omni).transferFrom(msg.sender,address(this),activeAmount[lvl]*10**18);
        IERC20(omni).safeApprove(stakePool, activeAmount[lvl]*10**18);
        IStakePool(stakePool).stake(activeAmount[lvl]*10**18);
        IStakePool(stakePool).stakePower(msg.sender,activeAmount[lvl]);
        activeStats[tokenId] = true;
    }
 
    function viewReward(uint256 tokenId) public view returns(uint256){
        uint256 lvl = IONFT(onft).getType(tokenId);
        address addr = IONFT(onft).ownerOf(tokenId);
        return nftReward[lvl] - claimedReward[tokenId];
    }

    function migrate(address token, address to, uint256 amount) external onlyAdmin {
        IERC20(token).safeTransfer(to, amount);
    }

    function updateToken(address pepe_) external onlyAdmin {
        PEPE = IERC20(pepe_);
    }
    
    function setNFT(address nft_) external onlyAdmin{
        require(nft_ != address(0),"Zero Address");
        onft = nft_;
    }

    function setStakePool(address pool_) external onlyAdmin{
        require(pool_ != address(0),"Zero Address");
        stakePool = pool_;
    }

}