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
}


contract OmniNFTPool is AdminRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    IERC20 public OMNI;
    address public onft;
    address public stakePool;
    uint256 public totalReward;
    uint256 public starttime; // starttime TBD
    mapping(uint256 => uint256) public nftReward;
    mapping(uint256 => uint256) public nftPower;
    mapping(uint256 => bool) public activeStats;
    mapping(uint256 => uint256) public claimedReward;

    constructor(
        address omni_,
        address nft_,
        uint256 starttime_
    ) {
        OMNI = IERC20(omni_);
        onft = nft_;
        starttime = starttime_;
        nftPower[1] = 100;
        nftPower[2] = 500;
        nftPower[3] = 1000;
        nftPower[4] = 5000;
        nftPower[5] = 10000;
        nftPower[6] = 50000;
        nftPower[7] = 100000;
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
            OMNI.safeTransfer(msg.sender, reward);
            claimedReward[tokenId] = nftReward[lvl];
        }
    }

    function active(uint256 tokenId) public  checkStart {
        uint256 lvl = IONFT(onft).getType(tokenId);
        address addr = IONFT(onft).ownerOf(tokenId);
        require(addr == msg.sender,"NFT OWNERSHIP ERROR");
        require(!activeStats[tokenId],"ACTIVE ALREADY");
        IStakePool(stakePool).stakePower(msg.sender,nftPower[lvl]);
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

    function updateToken(address omni_) external onlyAdmin {
        OMNI = IERC20(omni_);
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