// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20{
    function approve(address spender,uint amount) external returns(bool);
    function transfer(address to,uint value) external returns(bool);
    function balanceOf(address account) external view returns(uint);
}

interface IRouter{
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns(uint[] memory amounts);
}

contract FlashLoanArbitrage{
    address public owner;
    address public profitWallet;

    constructor(address _profitWallet){
        owner = msg.sender;
        profitWallet = _profitWallet;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function executeArbitrage(
        address router1,
        address router2,
        address tokenA,
        address tokenB,
        uint amount
    ) external onlyOwner {
        address ;

        path[0] = tokenA;
        path[1] = tokenB;

        IERC20(tokenA).approve(router1, amount);
        IRouter(router1).swapExactTokensForTokens(amount,1,path,address(this),block.timestamp);

        path[0] = tokenB;
        path[1] = tokenA;

        uint balance = IERC20(tokenB).balanceOf(address(this));
        IERC20(tokenB).approve(router2, balance);
        IRouter(router2).swapExactTokensForTokens(balance,1,path,address(this),block.timestamp);
    }

    function withdraw(address token) external onlyOwner{
        uint bal = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(profitWallet, bal);
    }
}
./git_push.sh
