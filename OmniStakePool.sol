// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface ISwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function setFeeTo(address) external;

    function initCodeHash() external view returns (bytes32);
    function feeTo() external view returns(address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint index) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function swapFee() external view returns (uint256);

    function sortTokens(address tokenA, address tokenB) external view returns (address token0, address token1);
    function pairFor(address tokenA, address tokenB) external view returns (address pair);
    function getReserves(address tokenA, address tokenB) external view returns (uint256 reserveA, uint256 reserveB);
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external view returns (uint256 amountB);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
    function router() external view returns(address);
}

interface IStakeFactory {
    function rewardSigner(address) external view returns (bool);
    function router() external view returns(address);
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface ISwapPair is IERC20 {
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;

    function burnToken(address token,uint amount) external;
    function distributeToken(address token,address[] memory feeAddressList, uint256[] memory feeList) external;
}
// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)
library SafeMath {
    uint256 constant WAD = 10 ** 18;
    uint256 constant RAY = 10 ** 27;

    function wad() public pure returns (uint256) {
        return WAD;
    }

    function ray() public pure returns (uint256) {
        return RAY;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function sqrt(uint256 a) internal pure returns (uint256 b) {
        if (a > 3) {
            b = a;
            uint256 x = a / 2 + 1;
            while (x < b) {
                b = x;
                x = (a / x + x) / 2;
            }
        } else if (a != 0) {
            b = 1;
        }
    }

    function wmul(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul(a, b) / WAD;
    }

    function wmulRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, b), WAD / 2) / WAD;
    }

    function rmul(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul(a, b) / RAY;
    }

    function rmulRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, b), RAY / 2) / RAY;
    }

    function wdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(mul(a, WAD), b);
    }

    function wdivRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, WAD), b / 2) / b;
    }

    function rdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(mul(a, RAY), b);
    }

    function rdivRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, RAY), b / 2) / b;
    }

    function wpow(uint256 x, uint256 n) internal pure returns (uint256) {
        uint256 result = WAD;
        while (n > 0) {
            if (n % 2 != 0) {
                result = wmul(result, x);
            }
            x = wmul(x, x);
            n /= 2;
        }
        return result;
    }

    function rpow(uint256 x, uint256 n) internal pure returns (uint256) {
        uint256 result = RAY;
        while (n > 0) {
            if (n % 2 != 0) {
                result = rmul(result, x);
            }
            x = rmul(x, x);
            n /= 2;
        }
        return result;
    }
}

interface IStakePool {
    function initialize(address _holder, address _lpAddr, uint256 _period, uint256 _ref, uint256 _limit, uint256 _start) external;
    function transferInitHolder(address _newHolder) external;
    function setDailyRewardHour(uint256 _hour) external;
}

interface ISwapRouter {
    function factory() external view returns(address);
    function baseTokenOf(address pair) external view returns (address base);
    function setWhiteList(address pair,address account,bool status) external;
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external view returns (uint256 amountB);
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/GSN/Context.sol
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/swap-libs/SafeERC20.sol
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/swap-libs/CfoTakeableV2.sol
// abstract contract CfoTakeableV2 is Ownable {
//     using Address for address;
//     using SafeERC20 for IERC20;

//     address public cfo;

//     modifier onlyCfoOrOwner {
//         require(msg.sender == cfo || msg.sender == owner(),"onlyCfo: forbidden");
//         _;
//     }

//     constructor(){
//         cfo = msg.sender;
//     }

//     function takeToken(address token,address to,uint256 amount) public onlyCfoOrOwner {
//         require(token != address(0),"invalid token");
//         require(amount > 0,"amount can not be 0");
//         require(to != address(0),"invalid to address");
//         IERC20(token).safeTransfer(to, amount);
//     }

//     function takeETH(address to,uint256 amount) public onlyCfoOrOwner {
//         require(amount > 0,"amount can not be 0");
//         require(address(this).balance>=amount,"insufficient balance");
//         require(to != address(0),"invalid to address"); 
//         payable(to).transfer(amount);
//     }

//     function takeAllToken(address token, address to) public onlyCfoOrOwner{
//         uint balance = IERC20(token).balanceOf(address(this));
//         if(balance > 0){
//             takeToken(token, to, balance);
//         }
//     }

//     function takeAllETH(address to) public onlyCfoOrOwner{
//         uint balance = address(this).balance;
//         if(balance > 0){
//             takeETH(to, balance);
//         }
//     }

//     function setCfo(address _cfo) external onlyOwner {
//         require(_cfo != address(0),"_cfo can not be address 0");
//         cfo = _cfo;
//     }
// }

// contract ECDSA {

//    function splitSignature(bytes memory sig)
//         internal
//         pure
//         returns (
//             uint8,
//             bytes32,
//             bytes32
//         )
//     {
//         require(sig.length == 65);

//         bytes32 r;
//         bytes32 s;
//         uint8 v;

//         assembly {
//             // first 32 bytes, after the length prefix
//             r := mload(add(sig, 32))
//             // second 32 bytes
//             s := mload(add(sig, 64))
//             // final byte (first byte of the next 32 bytes)
//             v := byte(0, mload(add(sig, 96)))
//         }
//         return (v, r, s);
//     }

//     function recoverSigner(bytes32 message, bytes memory sig)
//         internal
//         pure
//         returns (address)
//     {
//         uint8 v;
//         bytes32 r;
//         bytes32 s;
//         (v, r, s) = splitSignature(sig);
//         return ecrecover(message, v, r, s);
//     }
// }
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

contract AdminRole {
    using EnumerableSet for EnumerableSet.AddressSet;
 
    EnumerableSet.AddressSet private _admins;

    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

    constructor() {
        _addAdmin(msg.sender);
    }

    modifier onlyAdmin() {
        require(
            isAdmin(msg.sender),
            "AdminRole: caller does not have the Admin role"
        );
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return _admins.contains(account);
    }

    function allAdmins() public view returns (address[] memory admins) {
        admins = new address[](_admins.length());
        for (uint256 i = 0; i < _admins.length(); i++) {
            admins[i] = _admins.at(i);
        }
    }

    function addAdmin(address account) public onlyAdmin {
        _addAdmin(account);
    }

    function removeAdmin(address account) public onlyAdmin {
        _removeAdmin(account);
    }

    function renounceAdmin() public {
        _removeAdmin(msg.sender);
    }

    function _addAdmin(address account) internal {
        _admins.add(account);
        emit AdminAdded(account);
    }
    
    function _removeAdmin(address account) internal {
        _admins.remove(account);
        emit AdminRemoved(account);
    }
}

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


interface IRelation {
function Inviter(address addr) external view returns (address);
function bindLv(address addr) external view returns (uint256);
function invListLength(address addr) external view returns (uint256);
function getInvList(address addr_) external view returns(address[] memory);
}

interface INFTPOOL{
    function addReward(uint256 amount) external;
}


contract OmniStakePool is AdminRole{
    using SafeMath for uint;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 public dayId = 0;
    uint256 public dayPower = 102 * 10**16;


    uint256 public constant FEE_RATE_BASE = 10000;

    address public factory;
    address public stakeFactory;
    address public router;
    uint256 public period;
    address public lpAddress;
    address public initAddress = 0xAc81609078Ca25ea81935029dC78405650662334;
    uint256 public releaseRatio = 40;
    uint256 private initHolderAmount;
    address private initHolderAddress;
    uint256 public starttime;
    uint256 public checkTime;

    uint256 public lpReleaseTime;
    uint256 public rewardPeriod;
    uint256 public nextReleaseTime;
    uint256 public stakeNodeRatio = 500;
    uint256 public stakeFundRatio;
    uint256 public stakeCommRatio;
    address public fundAddress = 0x2C9b7E8D66081D4976A2d56FF1909f6A1F0B626B;
    address public feeAddress = 0xf955d0af234A957c78Ac612EF6fF9FeBc0F45283;
    address public commAddress = 0xE37E2d96c3Cc7C95ca8E99619C71B7F3e92444a6;
    address public operAddress = 0x390CC9768ED7D69184228536C22594db02A5128a;
    address public nftAddress = 0x4493CFd44f603bF85570302326dd417120bE6251;
    address public swapAddress = 0x28023C6B38D8c9F84B8cc8De7B3C31900a1e4553;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public lastReleaseAmount;
    uint256 public releaseFundRatio = 400;
    uint256 public releaseCommRatio = 200;
    uint256 public releaseOperRatio = 400;
    uint256 public releaseNftRatio = 500;
    uint256 public releaseBaseRatio = 5000;
    // address public fundAddr2;
    // address public commAddr2;
    address public baseToken;
    address public otherToken;
    address private _owner;
    bool public flag;
    bool public poolStatus = true;
    // mapping(address => uint256) private nonce;
    // mapping(bytes32 => bool) private orders;

    mapping(address => mapping(uint256 => uint256)) public dailyPower;
    // mapping(address => mapping(uint256 => uint256)) public TPower;
    // mapping(address => mapping(uint256 => uint256)) public NPower;

    uint256 public totalHashPower;
    mapping(address => uint256) public hashPower;
    mapping(address => uint256) public tPower;
    mapping(address => uint256) public nPower;
    mapping(address => uint256) public teamPower;

    uint private unlocked = 1;

    modifier lock() {
        require(unlocked == 1, 'Pool: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    event Claim(address user, address token, uint amount, uint rType, uint timeout, uint time);
    event Stake(address user, uint amount, uint time);
    event Release(uint amount, uint time);

    address public relation = 0x4cA03CaECEeB65Ae6b83fC6b3a02ab4823B407C6;
    uint256 public constant DURATION = 1 days; //days
    uint256 public initreward;
    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public lastUpdateTime; 
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public rewardClaimed;
    mapping(address => uint256) public totalDisClaimed;
    mapping(address =>mapping(uint256 => uint256)) public disReward;
    mapping(address =>mapping(uint256 => uint256)) public lastDisClaimed;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(
        // uint256 starttime_
    ) {
        // checkTime = starttime_;
        // starttime = starttime_;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalHashPower == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalHashPower)
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function getReward() public updateReward(msg.sender) checkStart {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewardClaimed[msg.sender] += reward;
            rewards[msg.sender] = 0;
            IERC20(otherToken).safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function helpGetReward(address addr_) external updateReward(addr_) checkStart onlyAdmin{
        uint256 reward = earned(addr_);
        if (reward > 0) {
            rewardClaimed[addr_] += reward;
            rewards[addr_] = 0;
            IERC20(otherToken).safeTransfer(addr_, reward);
            emit RewardPaid(addr_, reward);
        }
    }

    modifier checkStart() {
        require(block.timestamp >= starttime, "not start");
        _;
    }

    function updateStartTime(uint256 starttime_) external onlyAdmin {
        starttime = starttime_;
    }

    function updatePeriodFinish(uint256 time) external onlyAdmin {
        periodFinish = time;
    }

    function _addReward(uint256 reward) internal
        updateReward(address(0)) 
    {
        if (block.timestamp > starttime) {
            if (block.timestamp >= periodFinish) {
                rewardRate = reward.div(DURATION);
            } else {
                uint256 remaining = periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardRate);
                rewardRate = reward.add(leftover).div(DURATION);
            }
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(reward);
        } else {
            initreward = initreward + reward;
            rewardRate = initreward.div(DURATION);
            lastUpdateTime = starttime;
            periodFinish = starttime.add(DURATION);
            emit RewardAdded(reward);
        }
    }

    function _getTokenPrice() public view returns(uint256) {
        address token0 = ISwapPair(lpAddress).token0();
        address token1 = ISwapPair(lpAddress).token1();
        (uint112 token0Amount,uint112 token1Amount,)=ISwapPair(lpAddress).getReserves();
        uint256 price0 = uint256(token0Amount) * 10**18 / uint256(token1Amount);
        uint256 price1 = uint256(token1Amount) * 10**18 / uint256(token0Amount);
        if(token0 == baseToken){
            return price0;
        }
            return price1;
    }

    function _getSwapPrice() public view returns(uint256) {
        address token0 = ISwapPair(swapAddress).token0();
        address token1 = ISwapPair(swapAddress).token1();
        (uint112 token0Amount,uint112 token1Amount,)=ISwapPair(swapAddress).getReserves();
        uint256 price0 = uint256(token0Amount) * 10**18 / uint256(token1Amount);
        uint256 price1 = uint256(token1Amount) * 10**18 / uint256(token0Amount);
        if(token0 == baseToken){
            return price0;
        }
            return price1;
    }


    // called once by the factory at time of deployment
    function initialize(address _holder, address _lpAddr, uint256 _period, uint256 _ref, uint256 _limit, uint256 _start,address _router) external onlyAdmin{
        // require(msg.sender == stakeFactory, 'Pool: FORBIDDEN'); // sufficient check
        initHolderAddress = _holder;
        _owner = _holder;
        lpAddress = _lpAddr;
        period = _period;
        releaseRatio = _ref;
        initHolderAmount = _limit;
        starttime = _start;
        lpReleaseTime = block.timestamp;
        nextReleaseTime = computeNextReleaseTime(_start);
        checkTime = nextReleaseTime;
        // dailyRewardHour = 10;
        router = _router;
        factory = ISwapRouter(router).factory();
        IERC20(ISwapPair(_lpAddr).token0()).safeApprove(router, ~uint(0));
        IERC20(ISwapPair(_lpAddr).token1()).safeApprove(router, ~uint(0));
        IERC20(_lpAddr).safeApprove(router, ~uint(0));
        baseToken = ISwapRouter(router).baseTokenOf(_lpAddr);
        otherToken = ISwapPair(_lpAddr).token0() == baseToken ? ISwapPair(_lpAddr).token1() : ISwapPair(_lpAddr).token0();
    }

    modifier checkDayId() {
        if(block.timestamp >= checkTime + 86400){
            dayId++;
            dayPower = dayPower * 102/100;
            checkTime += 86400;
        }
        _;
    }


    function computeNextReleaseTime(uint256 _time) public view returns(uint256){
        return _time + period;
    }

    function setRewardPeriod(uint256 _hour) external onlyAdmin {
        rewardPeriod = _hour;
    }

    function setReleasePeriod(uint256 _hour) external onlyAdmin {
        period = _hour;
    }

    // function takeInitLp() public {
    //     require(msg.sender == initHolderAddress, "Pool: only init holder can take init lp");
    //     require(initHolderAmount > 0, "Pool: init lp token has been token");
    //     require(lpReleaseTime <= block.timestamp, "Pool:  Not yet time to release");
    //     if(IERC20(lpAddress).balanceOf(address(this)) < initHolderAmount) {
    //         IERC20(lpAddress).safeTransfer(msg.sender, IERC20(lpAddress).balanceOf(address(this)));
    //     } else {
    //         IERC20(lpAddress).safeTransfer(msg.sender, initHolderAmount);
    //     }
    //     initHolderAmount = 0;
    // }

    function addLock(uint _time) public onlyAdmin {
        require(!flag, "have been locked");
        lpReleaseTime = lpReleaseTime + _time;
        flag = true;
    }

    function takeToken(address token, address to, uint256 amount) public onlyAdmin {
        require(token == baseToken, "Pool: only base token can be taken");
        IERC20(token).safeTransfer(to, amount);
    }

    function setFeeInfo(address _fund, address _community, uint256 _fundFee, uint256 _commFee, uint256 _nodeFee) public onlyAdmin {
        fundAddress = _fund;
        stakeFundRatio = _fundFee;
        commAddress = _community;
        stakeCommRatio = _commFee;
        stakeNodeRatio = _nodeFee;
    }

    function setStartTime(uint256 _start) public onlyAdmin {
        starttime = _start;
        nextReleaseTime = computeNextReleaseTime(_start);
        checkTime = nextReleaseTime;
    }

    function setPoolStatus(bool _value) public onlyAdmin {
        poolStatus = _value;
    }

    // function setFeeInfo2(address _fund, address _comm, address _operate, uint256 _fundFee, uint256 _commFee, uint256 _operateFee) public onlyAdmin {
    //     fundAddr = _fund;
    //     releaseFundRatio = _fundFee;
    //     commAddr = _comm;
    //     releaseCommRatio = _commFee;
    //     operAddr = _operate;
    //     releaseOperRatio = _operateFee;
    // }

    function transferOwnership(address _newOwner) public {
        require(_owner == msg.sender, "Pool: only owner can transfer ownership");
        _owner = _newOwner;
    }

    // function transferInitHolder(address _newHolder) public {
    //     require(msg.sender == stakeFactory, 'Pool: FORBIDDEN'); // sufficient check
    //     initHolderAddress = _newHolder;
    // }

    function removeLiqRelease() external checkDayId lock {
        require(block.timestamp >= nextReleaseTime, "Pool: Not yet time to release");
        require(ISwapPair(lpAddress).balanceOf(address(this)) > 0, "Pool: No tokens to release");
        uint initBalance = IERC20(otherToken).balanceOf(address(this));
        uint amountToRelease = ISwapPair(lpAddress).balanceOf(address(this)).mul(releaseRatio).div(FEE_RATE_BASE);
        address tokenA = ISwapPair(lpAddress).token0();
        address tokenB = ISwapPair(lpAddress).token1();
        (uint amountA, uint amountB) = ISwapRouter(router).removeLiquidity(
            tokenA, tokenB, amountToRelease, 0, 0, address(this), block.timestamp + 300);

        (address token0,) = ISwapFactory(factory).sortTokens(tokenA, tokenB);
        (uint amount0, uint amount1) = tokenA == token0 ? (amountA, amountB) : (amountB, amountA);
    
        uint usdtAmount = tokenA == ISwapRouter(router).baseTokenOf(lpAddress) ? amount0 : amount1;
        address[] memory path = new address[](2);
        path[0] = baseToken;
        path[1] = otherToken;
        ISwapRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount, 0, path, address(this), block.timestamp + 300);
        nextReleaseTime = computeNextReleaseTime(nextReleaseTime);
        uint addBalance = IERC20(otherToken).balanceOf(address(this)).sub(initBalance);
        lastReleaseAmount = addBalance;
        if(releaseFundRatio > 0) {
            IERC20(otherToken).safeTransfer(fundAddress, addBalance.mul(releaseFundRatio).div(FEE_RATE_BASE));
        }
        if(releaseCommRatio > 0) {
            IERC20(otherToken).safeTransfer(commAddress, addBalance.mul(releaseCommRatio).div(FEE_RATE_BASE));
        }
        if(releaseOperRatio > 0) {
            IERC20(otherToken).safeTransfer(operAddress, addBalance.mul(releaseOperRatio).div(FEE_RATE_BASE));
        }
        if(releaseNftRatio > 0) {
            IERC20(otherToken).safeTransfer(nftAddress, addBalance.mul(releaseNftRatio).div(FEE_RATE_BASE));
            INFTPOOL(nftAddress).addReward(addBalance.mul(releaseNftRatio).div(FEE_RATE_BASE));
        }
        _addReward(addBalance * releaseBaseRatio/FEE_RATE_BASE);
        
        emit Release(addBalance, block.timestamp);
    }


    function stakePower(address addr, uint256 amount) public checkDayId onlyAdmin {       
        _hashUpdate(addr,amount*10**18);
        _teamUpdate(addr,amount*10**18);
        emit Stake(addr, amount, block.timestamp);
    }


    // function unstakePower(address addr, uint256 amount) public onlyAdmin updateReward(addr){       
    //     uint256 power = amount* dayPower;
    //     hashPower[addr] -= power;
    //     totalHashPower -= power;
    // }

    function batchStakePower(address[] memory addrs, uint256[] memory amounts) public checkDayId onlyAdmin {       
        require(addrs.length == amounts.length,"DATA ERROR");
        for(uint256 i =0;i< addrs.length;i++){
        _hashUpdate(addrs[i],amounts[i]);
        _teamUpdate(addrs[i],amounts[i]);
        emit Stake(addrs[i], amounts[i], block.timestamp);
        }
    }
    
    // function stake(uint256 amount) external  checkDayId lock {
    //     require(amount >= 100e18, 'Pool: stake amount must be greater than 100');
    //     require(block.timestamp >= starttime, 'Pool: NOT START');
    //     IERC20(baseToken).safeTransferFrom(msg.sender, address(this), amount);
    //     uint256 usdtAmount = amount.div(2);
    //     address[] memory path = new address[](2);
    //     path[0] = baseToken;
    //     path[1] = otherToken;
    //     uint256 initialBalance = IERC20(otherToken).balanceOf(address(this));
    //     ISwapRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //         usdtAmount, 0, path, address(this), block.timestamp + 300);
    //     uint256 newBalance = IERC20(otherToken).balanceOf(address(this)).sub(initialBalance);
    //     ISwapRouter(router).addLiquidity(
    //         baseToken, otherToken, usdtAmount, newBalance, 0, 0, address(this), block.timestamp + 300);
    //     emit Stake(msg.sender, amount, block.timestamp);
    //     _hashUpdate(msg.sender,amount);
    // }

    function stake(uint256 amount) external checkDayId lock {
        require(amount >= 100e18, 'Pool: stake amount must be greater than 100');
        require(block.timestamp >= starttime, 'Pool: NOT START');
        if(poolStatus){
        IERC20(baseToken).safeTransferFrom(msg.sender, address(this), amount);
        uint256 usdtAmount = amount.div(2);
        address[] memory path = new address[](2);
        path[0] = baseToken;
        path[1] = otherToken;
        uint256 initialBalance = IERC20(otherToken).balanceOf(address(this));
        ISwapRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount, 0, path, address(this), block.timestamp + 300);
        uint256 newBalance = IERC20(otherToken).balanceOf(address(this)).sub(initialBalance);
        IERC20(otherToken).safeTransfer(feeAddress, newBalance * stakeNodeRatio/FEE_RATE_BASE);
        ISwapRouter(router).addLiquidity(
            baseToken, otherToken, usdtAmount, newBalance - newBalance * stakeNodeRatio/FEE_RATE_BASE, 0, 0, address(this), block.timestamp + 300);
        }
        else{
        IERC20(baseToken).safeTransferFrom(msg.sender, initAddress, amount);
        }

        emit Stake(msg.sender, amount, block.timestamp);
        _hashUpdate(msg.sender,amount);
        _teamUpdate(msg.sender,amount);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
        ) external checkDayId lock {
        require(tokenA == baseToken,"Wrong Token");
        require(tokenB == otherToken,"Wrong Token");
        require(amountADesired >= 100e18, 'Pool: stake amount must be greater than 100');
        IERC20(baseToken).safeTransferFrom(msg.sender, address(this), amountADesired);
        IERC20(otherToken).safeTransferFrom(msg.sender, deadAddress, amountBDesired);
        uint256 usdtAmount = amountADesired.div(2);
        address[] memory path = new address[](2);
        path[0] = baseToken;
        path[1] = otherToken;
        uint256 initialBalance = IERC20(otherToken).balanceOf(address(this));
        ISwapRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount, 0, path, address(this), block.timestamp + 300);
        uint256 newBalance = IERC20(otherToken).balanceOf(address(this)).sub(initialBalance);
        IERC20(otherToken).safeTransfer(feeAddress, newBalance * stakeNodeRatio/FEE_RATE_BASE);
        ISwapRouter(router).addLiquidity(
            baseToken, otherToken, usdtAmount, newBalance - newBalance * stakeNodeRatio/FEE_RATE_BASE, 0, 0, address(this), block.timestamp + 300);
        uint256 price = _getSwapPrice();
        uint256 amount = (amountADesired + amountBDesired*price/10**18)*105/100;
        emit Stake(msg.sender, amount, block.timestamp);
        _hashUpdate(msg.sender,amount);
        _teamUpdate(msg.sender,amount);
    }


    function _teamUpdate(address account,uint256 amount) internal {
        uint256 Lv = IRelation(relation).bindLv(account);
        address inv = IRelation(relation).Inviter(account);
        for(uint256 i = 0;i<Lv;i++){
            teamPower[inv] += amount* dayPower/10**18;
            inv = IRelation(relation).Inviter(inv);
        }
    }

    function batchTeamUpdate(address[] memory accounts) external onlyAdmin {
        // require(accounts.length == amounts.length,"DATA ERROR");
        for(uint256 i=0;i<accounts.length;i++){
            address addr = accounts[i];
            uint256 amount = hashPower[addr];
            _teamUpdate(addr,amount);
        }     
    }

    function _hashUpdate(address account,uint256 amount) internal updateReward(account){
        uint256 power = amount* dayPower/10**18;
        hashPower[account] += power;
        totalHashPower += power;
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens (
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) 
    external  checkDayId lock
    {
        require(path[0] == otherToken,"Token Error");
        uint256 initialBalance = IERC20(otherToken).balanceOf(address(this));
        IERC20(otherToken).safeTransferFrom(msg.sender, feeAddress, amountIn * stakeNodeRatio/FEE_RATE_BASE);
        IERC20(otherToken).safeTransferFrom(msg.sender, address(this), amountIn - amountIn * stakeNodeRatio/FEE_RATE_BASE);
        uint256 newAmountIn = IERC20(otherToken).balanceOf(address(this)).sub(initialBalance);
        ISwapRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            newAmountIn, amountOutMin, path, to, block.timestamp + 300);
        uint256 price = _getTokenPrice();
        uint256 amount = newAmountIn * price * 45 / 10**20;
        _hashUpdate(msg.sender,amount);
        _teamUpdate(msg.sender,amount);
        emit Stake(msg.sender, amount, block.timestamp);
    }


    function balanceOf(address account) public view returns (uint256) {
        return hashPower[account];
    }


    function viewTAmount(address account) public view returns(uint256){
        uint256 length = IRelation(relation).invListLength(account);
        uint256 tAmount;
        address[] memory team= IRelation(relation).getInvList(account);
        for(uint256 i=0;i<length;i++){
            address addr =  team[i];
            uint256 amount = (hashPower[addr] + hashPower[addr]*hashPower[account]/(hashPower[addr]+hashPower[account])) * lastReleaseAmount/totalHashPower;
            tAmount += amount;
        }
        return tAmount;
    }

    function batchUpdateTPower(address[] memory accounts) external onlyAdmin { 
        for(uint256 i=0;i<accounts.length;i++){
            address addr = accounts[i];
            uint256 tAmount = viewTAmount(addr);
            if(tAmount >0 && tPower[addr] != tAmount){
            tPower[addr] = tAmount;
            }
        }     
    }

    function viewNAmount(address account) public view returns(uint256){
        uint256 length = IRelation(relation).invListLength(account);
        uint256 nAmount;
        address[] memory team= IRelation(relation).getInvList(account);
        for(uint256 i=0;i<length;i++){
            address addr =  team[i];
            // uint256 tAmount = viewTAmount(addr);
            nAmount += tPower[addr];
        }
        return nAmount;
    }

    function batchUpdateNPower(address[] memory accounts) external onlyAdmin {
        for(uint256 i=0;i<accounts.length;i++){
             address addr = accounts[i];
             uint256 nAmount = viewNAmount(addr);
            if(nAmount >0 && tPower[addr] != nAmount){            
             nPower[addr] = nAmount;
            }     
        }
    }


    function batchDisReward(address[] memory addrs,uint256[] memory amounts, uint256 typeID) external onlyAdmin{
        require(addrs.length == amounts.length,"DATA ERROR");
        for(uint256 i=0;i<addrs.length;i++){
        address addr = addrs[i];
        disReward[addr][typeID] += amounts[i];
    }
    }


    function batchResReward(address[] memory addrs,uint256[] memory amounts, uint256 typeID) external onlyAdmin{
        require(addrs.length == amounts.length,"DATA ERROR");
        for(uint256 i=0;i<addrs.length;i++){
        address addr = addrs[i];
        disReward[addr][typeID] -= amounts[i];
    }
    }



    function claim() checkDayId external {
        // require(disReward[msg.sender][typeID] > 0,"No Reward to Claim");
        for(uint256 i = 1; i<5;i++){
        if(disReward[msg.sender][i]>0){
        uint256 reward = disReward[msg.sender][i];
        totalDisClaimed[msg.sender] += reward;
        lastDisClaimed[msg.sender][dayId] += reward;
        IERC20(otherToken).safeTransfer(msg.sender, reward);  
        disReward[msg.sender][i] = 0;
        emit RewardPaid(msg.sender, reward);
        }
        }
    }

}