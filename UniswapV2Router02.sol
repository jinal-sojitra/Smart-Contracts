pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Router02{
    address public immutable factory;
    event UniswapRouter(uint amountOut, bool isSuccess);
    event RouterAddLiquidity(uint liquidity, bool isSuccess);

    constructor(address _factory) {
        factory = _factory;
    }

    receive() external payable {}

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        address pair
    ) external virtual returns (uint liquidity) {
        ERC20(tokenA).transferFrom(msg.sender, pair, amountADesired);
        ERC20(tokenB).transferFrom(msg.sender, pair, amountBDesired);
        (uint reserveA, uint reserveB,) = IUniswapV2Pair(pair).getReserves();
        uint amountAMin = (amountADesired * 1000) / 997; // 0.3% slippage
        uint amountBMin = (amountBDesired * 1000) / 997; // 0.3% slippage
        require(amountADesired > 0 && amountBDesired > 0, "Router: INSUFFICIENT_LIQUIDITY");
        require(reserveA > 0 && reserveB > 0, "Router: NO_RESERVES");
        ERC20(tokenA).transfer(pair, amountAMin);
        ERC20(tokenB).transfer(pair, amountBMin);
        liquidity = IUniswapV2Pair(pair).mint(address(this));
        ERC20(pair).transfer(msg.sender, liquidity);
        emit RouterAddLiquidity(liquidity, true);
    }

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint) {
        uint amountInWithFee = amountIn * 997;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = (reserveIn * 1000) + amountInWithFee;
        return numerator / denominator;
    }

    function swap(
        address inputToken,
        uint amountIn,
        address pair
    ) external returns (bool) {
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
        address token0 = IUniswapV2Pair(pair).token0();
        (reserve0, reserve1) = inputToken == token0? (reserve0, reserve1): (reserve1, reserve0);
        ERC20(token0).transferFrom(msg.sender, pair, amountIn);
        uint amountOut = getAmountOut(amountIn, reserve0, reserve1);
        (uint amount0Out, uint amount1Out) = inputToken == token0? (uint(0), amountOut): (amountOut, uint(0));
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, msg.sender, "");
        emit UniswapRouter(amountOut, true);
        return true;
    }
}
