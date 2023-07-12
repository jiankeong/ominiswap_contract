//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@openzeppelin/contracts/utils/math/Math.sol";

import "./AdminRole.sol";


interface INFT {
    function mint(address to, uint256 typeId, uint256 number) external;
    function totalSupplyOfType(uint256 typeId) external view returns (uint256);
} 

interface IRelation {
function Inviter(address addr) external view returns (address);
function bindLv(address addr) external view returns (uint256);
function vip(address addr) external view returns (uint256);
function invStats(address addr) external view returns (bool);
function BatchBind(address[] memory addr,address[] memory inv) external;
function getDirectCard(address addr) external view returns (address);
function getIndirectCard(address addr) external view returns (address);
}




contract OMINT is AdminRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    address public relation;
    address public onft;
    address public fundAddress = 0xAc81609078Ca25ea81935029dC78405650662334;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    
    address[] public studioList;
    mapping(address => bool) public studioStats;
    mapping(address => uint256) public studioAmount;
    mapping(address => bool) public mintStats;
    mapping(uint256 => bool) public mintPause;
   mapping(uint256 => uint256) public price;
    mapping(uint256 => uint256) public amountForType;
    constructor(address onft_,address relation_){
      onft = onft_;
      relation = relation_;
      price[1] = 100* 10** 18;
      price[2] = 500* 10** 18;
      price[3] = 1000* 10** 18;
      price[4] = 5000* 10** 18;
      price[5] = 10000* 10** 18;
      price[6] = 50000* 10** 18;
      price[7] = 100000* 10** 18;
      amountForType[1] = 500;
      amountForType[2] = 500;     
      amountForType[3] = 1000;
      amountForType[4] = 500;
      amountForType[5] = 300;
      amountForType[6] = 200;
      amountForType[7] = 100;
    }

  modifier callerIsUser() {
    require(tx.origin == msg.sender, "The caller is another contract");
    _;
  }

  function Mint(uint256 typeID) external callerIsUser {
    require(
      INFT(onft).totalSupplyOfType(typeID) < amountForType[typeID],
      "Insufficient reserve to support desired mint amount"
    );
    require(
      !mintPause[typeID],
      "Insufficient reserve to support desired mint amount"
    );
    require(
      IRelation(relation).invStats(msg.sender),
      "Not Bind Yet"
    );
    require(
      !mintStats[msg.sender],
      "This Address have got NFT already"
    );
    uint256 USDTAmount = price[typeID];
    IERC20(USDT).transferFrom(msg.sender,fundAddress,USDTAmount/1000000); 
    INFT(onft).mint(msg.sender,typeID,1);
    mintStats[msg.sender] = true;
    _record(msg.sender,USDTAmount);
    }

  function DevMint(address addr,uint256 typeID) external onlyAdmin {
    require(
      INFT(onft).totalSupplyOfType(typeID) < amountForType[typeID],
      "Insufficient reserve to support desired mint amount"
    );
    INFT(onft).mint(addr,typeID,1);
    mintStats[addr] = true;
    uint256 USDTAmount = price[typeID];
    _record(addr,USDTAmount);
    }
 
  function BatchDevMint(address[] memory addrs,uint256[] memory typeIDs) external onlyAdmin {
    for(uint256 i = 0; i < addrs.length; i++ ){
    require(
      INFT(onft).totalSupplyOfType(typeIDs[i]) < amountForType[typeIDs[i]],
      "Insufficient reserve to support desired mint amount"
    );
    address addr = addrs[i];
    uint256 typeId = typeIDs[i];
    INFT(onft).mint(addr,typeId,1);
    mintStats[addr] = true;
    uint256 USDTAmount = price[typeId];
    _record(addr,USDTAmount);
    }
    }

    function _record(address addr, uint256 amount) internal {
     uint256 bindLv = IRelation(relation).bindLv(addr);   
     address inv = IRelation(relation).Inviter(addr);
     for(uint256 i = 0 ; i< bindLv;i++){
        if(studioStats[inv]){
            studioAmount[inv] += amount;
            break;
        }
        inv = IRelation(relation).Inviter(inv);
     }
    }



    function setStudioAdmin(address addr, bool value) external onlyAdmin{
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


    function getStudioList()
        public view
        returns(address[] memory _addrsList)
    {
        _addrsList = new address[](studioList.length);
        for(uint256 i=0;i<studioList.length;i++){
            _addrsList[i] = studioList[i];
        }
    }

  function setRelation(address relation_) external onlyAdmin {
    relation = relation_;
  }

  function setPause(uint256 typeId, bool value) external onlyAdmin {
    mintPause[typeId] = value;
  }

  function setFundAddress(address addr) external onlyAdmin {
    fundAddress = addr;
  }



    }

