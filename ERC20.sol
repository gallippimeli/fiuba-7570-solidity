pragma solidity ^0.5.8;

import './IERC20.sol';
import './SafeMath.sol';
import './TransactionsManager.sol';

pragma experimental ABIEncoderV2;

contract ERC20 is IERC20, TransactionsManager {
    using SafeMath for uint256;

    /**
     * Public variables
     */
    string public symbol = "LEM";

    string public name = "LEMA";

    uint8 public decimals = 18;

    /**
     * Private variables
     */
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply = 2000;

    uint private _price = 10;

    /**
     * Implemented IERC20 functions
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * Additional functions
     */
    function buyCoins(uint amount) public payable {
        require(
            transfer(msg.sender, amount),
            'No puedes comprar monedas'
        );
        _increasePrice();
        addTransaction(_price);
    }

    function sellCoins(uint amount) public payable {
        require(
            _balances[msg.sender] >= amount,
            'No puedes vender monedas'
        );
        uint amountEther = amount.mul(_price).div(10**uint(decimals));
        //msg.sender.transfer(amountEther);
        _decreasePrice();
        _balances[msg.sender] -= amount;
        addTransaction(_price);
    }

    /**
     * Private functions
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(sender != msg.sender){
            _balances[sender] = _balances[sender].sub(amount);
        }
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _increasePrice() internal {
        _price++;
    }

    function _decreasePrice() internal {
        if (_price > 0) {
            _price--;
        }
    }
}
