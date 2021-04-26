// SPDX-License-Identifier: UNLICENSED

/* Pragma definition, including version pragma and experimental pragma */
pragma solidity ^0.8.0;
// pragma experimental SMTChecker;

/* Imports */
import "./IERC20.sol";

/* YZT main contract, inherit from IERC20 */
contract YZT is IERC20 {
    
    /* [uint] YZT total supply */ 
    uint256 private _totalSupply;

    /* [uint] token decimal */
    uint8 private _decimal;

    /* [string] YZT token name */
    string private _name;
    
    /* [string] YZT token symbol */
    string private _symbol;
    
    /* [bool] breaker for logging transfer */
    bool recorded = false;
    
    /* [address] owner of this contract */
    address public owner;
    
    /* [struct] definition of transfer log */
    struct TransferLog {
        address _sender;
        address _receiver;
        uint _amount;
        uint _time;
    }
    
    /* [array] array for transfer logs */
    TransferLog[] private _transferLog;
    
    /* [mapping] balances definition */
    mapping (address => uint256) private _balances;
    
    /* [mapping] allowance definition */
    mapping (address => mapping (address => uint256)) private _allowances;

    constructor (string memory name_, string memory symbol_, uint8 decimal_, uint totalSupply_) {
        owner = msg.sender;

        _name = name_;
        _symbol = symbol_;
        _decimal = decimal_;
        _totalSupply = totalSupply_;

        _mint(owner, _totalSupply);
    }

    function decimal() public view virtual returns (uint8) {
        return _decimal;
    }

    function totalSupply() public view virtual override returns (uint) {
        return _totalSupply;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * Requirements:
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * -  Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
      address sender = msg.sender;
      require(sender != address(0), "ERC20: transfer from the zero address");
      require(recipient != address(0), "ERC20: transfer to the zero address");

      uint256 senderBalance = _balances[sender];
      require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
      _balances[sender] = senderBalance - amount;
      _balances[recipient] += amount;

      emit Transfer(sender, recipient, amount);

      return true;
    }

    function allowance(address origin, address spender) public view virtual override returns (uint256) {
      return _allowances[origin][spender];
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * Requirements:
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     * - Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
      address origin = msg.sender;
      require(origin != address(0), "ERC20: approve from the zero address");
      require(spender != address(0), "ERC20: approve to the zero address");

      _allowances[origin][spender] = amount;
      emit Approval(origin, spender, amount);

      return true;
    }

    /**
     * @dev Transfer token from sender to receiver by a spender
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     * -  Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
      require(sender != address(0), "ERC20: transfer from the zero address");
      require(recipient != address(0), "ERC20: transfer to the zero address");

      address spender = msg.sender;
      uint256 currentAllowance = _allowances[sender][spender];
      require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
      approve(spender, currentAllowance - amount);

      uint256 senderBalance = _balances[sender];
      require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
      _balances[sender] = senderBalance - amount;
      _balances[recipient] += amount;

      emit Transfer(sender, recipient, amount);

      return true;
    }

     /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
      address origin = msg.sender;
      uint256 currentAllowance = _allowances[origin][spender];

      approve(spender, currentAllowance + addedValue);

      return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
      address origin = msg.sender;
      uint256 currentAllowance = _allowances[origin][spender];
      require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
      approve(spender, currentAllowance - subtractedValue);

      return true;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }
}
 
