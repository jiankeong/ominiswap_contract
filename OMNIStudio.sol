//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@openzeppelin/contracts/utils/math/Math.sol";

import "./AdminRole.sol";




interface IRelation {
function Inviter(address addr) external view returns (address);
function bindLv(address addr) external view returns (uint256);
function vip(address addr) external view returns (uint256);
function invStats(address addr) external view returns (bool);
function BatchBind(address[] memory addr,address[] memory inv) external;
function getDirectCard(address addr) external view returns (address);
function getIndirectCard(address addr) external view returns (address);
}




contract OMNIStudio is AdminRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    address public relation;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    
    address[] public studioList;
    mapping(address => bool) public studioStats;

    constructor(address relation_){
        relation = relation_;
    }


    function setStudioAdmin(address addr,bool value) external onlyAdmin{
        if(!studioStats[addr]&&value){
            studioList.push(addr); 
            studioStats[addr] = value;
        }
        else if(!value&&studioStats[addr]){       
        uint256 num = studioList.length-1;
        for(uint256 i=0;i< studioList.length;i++){
            if(studioList[i] == addr){
                studioList[i] = studioList[num]; 
                studioList.pop();
                studioStats[addr] = value;
                break;
            }       
            }
        }
        }

    function studioListLength() public view returns(uint256)
    {
        return studioList.length;
    }

    function getStudioStats(address[] memory addrs)
        public view
        returns(address[] memory _addrsList)
    {
        _addrsList = new address[](addrs.length);
        for(uint256 i=0;i<addrs.length;i++){
            // uint256 bindLv = IRelation(relation).bindLv(addrs[i]);
            address inv = IRelation(relation).Inviter(addrs[i]);
            for(uint256 j=0;j<100;j++){
            if(studioStats[inv] || inv == address(0)){
                _addrsList[i] = inv;
                break;
            }
            address inv = IRelation(relation).Inviter(inv);
            }
            
        }
    }

    function getInvStats(address addr, uint256 lv)
        public view
        returns(address[] memory _addrsList)
    {
        _addrsList = new address[](lv);
            address inv = IRelation(relation).Inviter(addr);
            for(uint256 i=0;i<lv;i++){
            if(studioStats[inv] || inv== address(0)){
                _addrsList[i] = inv;
                break;
            }
            inv = IRelation(relation).Inviter(inv);
            }
            
    }




    }

