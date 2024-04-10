// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external payable returns (bool);

    // function allowance(
    //     address owner,
    //     address spender
    // ) external view returns (uint256);

    // function approve(address spender, uint256 amount) external returns (bool);

    // function transferFrom(
    //     address sender,
    //     address recipient,
    //     uint256 amount
    // ) external returns (bool);

    // function permit(
    //     address target,
    //     address spender,
    //     uint256 value,
    //     uint256 deadline,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s
    // ) external;

    // function transferWithPermit(
    //     address target,
    //     address to,
    //     uint256 value,
    //     uint256 deadline,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s
    // ) external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokenAmount
    );

    event AddLiquidity(uint32 _blockToUnlockLiquidity, uint256 value);

    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out
    );

    event Saled(address indexed from, uint256 tokenValue, uint256 value);

    event Bought(address indexed from, uint256 tokenValue, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract mm314 is IERC20 {
    string public constant name = "MM314";
    string public constant symbol = "MM314";
    uint8 public immutable override decimals = 18;

    /// @dev Records amount of token owned by account.
    mapping(address => uint256) public override balanceOf;
    uint256 private _totalSupply;
    // uint256 private balanceOfPool;

    //
    uint256 public taxBalance; // tax fee
    uint256 public poolBalance; //

    // configurable delay for timelock functions
    uint public constant transferDelay = 60; // seconds

    // set of minters, can be this bridge or other bridges
    mapping(address => bool) public isMinter;

    address public immutable creator;

    constructor(uint256 _i_totalSupply, uint256 _creatorInitAmount) payable {
        require(msg.value > 0, "need supply main coin value.11");
        require(
            _i_totalSupply >= 21000000,
            "need _i_totalSupply equal or more than 21000000"
        );

        address thisAddr = address(this);
        creator = msg.sender;
        taxBalance = getTax(msg.value);
        poolBalance = msg.value - taxBalance;
        _totalSupply = _i_totalSupply * 1000000000000000000; // 18个0
        balanceOf[creator] = _creatorInitAmount * 1000000000000000000; // 18个0
        balanceOf[thisAddr] = _totalSupply - balanceOf[creator]; // balanceOfPool;

        // emit Transfer(thisAddr, creator, balanceOf[creator]);
        emit Transfer(thisAddr, thisAddr, balanceOf[thisAddr]);
    }

    function getTax(uint256 val) internal pure returns (uint256) {
        return 0;
        // return (val * 1) / 1000;
    }

    /// @dev Returns the total supply of AnyswapV3ERC20 token as the ETH held in this contract.
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function getPoolAmount() internal view returns (uint256) {
        return balanceOf[address(this)];
    }

    function addLiquidity(uint32 _blockToUnlockLiquidity) public pure {
        require(1 == 2, "Liquidity already added");

        // emit AddLiquidity(_blockToUnlockLiquidity, msg.value);
    }

    function removeLiquidity() public pure {
        require(1 == 2, "Liquidity can't remove");
    }

    function transfer(
        address to,
        uint256 tokenValue
    ) external payable override returns (bool) {
        require(to != address(0));
        // uint256 balance = balanceOf[msg.sender];
        require(
            balanceOf[msg.sender] >= tokenValue,
            "transfer amount exceeds balance."
        );

        balanceOf[msg.sender] -= tokenValue;
        balanceOf[to] += tokenValue;
        emit Transfer(msg.sender, to, tokenValue);

        if (to == address(this)) {
            // trigger sell
            uint256 xx = getPoolAmount() + tokenValue;
            uint256 obtainMoney = (poolBalance * tokenValue) / xx;
            uint256 tax = getTax(obtainMoney);
            obtainMoney -= tax;

            payable(address(msg.sender)).transfer(obtainMoney);
            poolBalance -= (obtainMoney + tax);
            taxBalance += tax;

            // emit Saled(msg.sender, tokenValue, msg.value);
            emit Swap(msg.sender, 0, tokenValue, obtainMoney, 0);
        }

        return true;
    }

    receive() external payable {
        require(msg.value > 0, "need more than zero.");

        // trigger buy
        uint256 tax = getTax(msg.value);
        uint256 money = msg.value - tax;

        uint256 obtainTokenValue = (balanceOf[address(this)] * money) /
            (poolBalance + money);

        balanceOf[address(this)] -= obtainTokenValue;
        balanceOf[msg.sender] += obtainTokenValue;

        poolBalance += money;
        taxBalance += tax;

        // emit Bought(msg.sender, obtainTokenValue, msg.value);
        emit Transfer(address(this), msg.sender, obtainTokenValue);
        emit Swap(msg.sender, msg.value, 0, 0, obtainTokenValue);
    }
}
