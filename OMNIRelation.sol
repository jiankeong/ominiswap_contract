//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../owner/AdminRole.sol";
interface IOMNINFT {
    function ownerOf(uint256 _nftNo) external view returns (address);
    function balanceOf(address _addr) external view returns (uint256);
    function getNFTlvl(address _addr) external view returns (uint256);
    function nftID(address _addr) external view returns (uint256);
    function getNFTlvlID(uint256 _nftNo) external view returns (uint256);

}



contract OMNIRelation is AdminRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    address public omninft;
    uint256 public totalIndex;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public _burnAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => address) public Inviter;
    mapping(address => uint256) public bindLv;
    mapping(address => bool) public invStats;
    mapping(address => uint256) public vip;
    mapping(address => uint256) public Index;
    mapping(uint256 => uint256) public nftIndex;
    mapping(address => address[]) public invList;

    constructor(address nft_){
        omninft = nft_;
        // WK = wk_;
        invStats[0x3DeEF4EA4086EAFDa8a2c193A3693DC60DeC07D6] = true;
        invStats[0x1FAbBa9dfFb82673f70db78359c04Fd655D31c1e] = true; 
        bindLv[0x3DeEF4EA4086EAFDa8a2c193A3693DC60DeC07D6] =1;
        bindLv[0x1FAbBa9dfFb82673f70db78359c04Fd655D31c1e] =1;
        nftIndex[0] = 40;
        nftIndex[1] = 20;
        nftIndex[2] = 10;
        nftIndex[3] = 2;
    }


    function bind(address addr) 
    public 
    {
        require(!invStats[msg.sender],"BIND ERROR: ONCE BIND");
        require(invStats[addr],"BIND ERROR: INVITER NOT BIND");
        _bind(addr,msg.sender);
    }


    function _bind(address addr,address newaddr) 
    internal 
    {
        Inviter[newaddr] = addr;
        invList[addr].push(newaddr);
        invStats[newaddr]= true;
        bindLv[newaddr] = bindLv[addr] +1 ;
    }


    function BatchBind(address[] memory addrs, address[] memory invs) external onlyAdmin{
        for(uint256 i = 0; i < addrs.length; i++ ){
            _bind(invs[i],addrs[i]);
        }
    }

    function setBindLv(address addr_, uint256 lv_) external onlyAdmin{
        bindLv[addr_] = lv_;
    }

    function BatchSetBindLv(address[] memory addrs, uint256[] memory lvls) external onlyAdmin{
        for(uint256 i=0;i< addrs.length;i++){
        bindLv[addrs[i]] = lvls[i];
        }
    }


    function setNFT(address nft_) external onlyAdmin{
        require(nft_ != address(0),"Zero Address");
        omninft = nft_;
    }

    function invListLength(address addr_) public view returns(uint256)
    {
        return invList[addr_].length;
    }

    function getInvList(address addr_)
        public view
        returns(address[] memory _addrsList)
    {
        _addrsList = new address[](invList[addr_].length);
        for(uint256 i=0;i<invList[addr_].length;i++){
            _addrsList[i] = invList[addr_][i];
        }
    }


    function Migrate(address token, address to, uint256 amount) external onlyAdmin {
        IERC20(token).safeTransfer(to, amount);
    }

    function setStates(address addr) external onlyAdmin{
        invStats[addr]= true;
    }


    }

