// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Pool is Ownable, Pausable {
    using SafeERC20 for IERC20;

    // Token Price Mapping (price stored in 18 decimal format)
    mapping(address => uint256) private _tokenPrice;

    // Events
    event TokenPriceUpdated(address indexed token, uint256 price);
    event TokenSwapped(address indexed user, address indexed token, uint256 amount);
    event NativeReceived(address indexed user, uint256 amount);

    constructor() Ownable(msg.sender) {}

    receive() external payable {
        emit NativeReceived(msg.sender, msg.value);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function swap(address _recipient, address _token) external payable whenNotPaused {
        require(_token != address(0), "INVALID_TOKEN_ADDRESS");
        require(_tokenPrice[_token] > 0, "TOKEN_PRICE_NOT_SET");
        require(msg.value > 0, "INVALID_NATIVE_AMOUNT");
        
        uint256 tokenAmount = (msg.value * 1e18) / _tokenPrice[_token];

        require(IERC20(_token).balanceOf(address(this)) >= tokenAmount, "INSUFFICIENT_TOKEN_BALANCE");

        IERC20(_token).safeTransfer(_recipient, tokenAmount);

        emit TokenSwapped(_recipient, _token, tokenAmount);
    }

    function setTokenPrice(address _token, uint256 _price) external onlyOwner {
        require(_token != address(0), "INVALID_TOKEN_ADDRESS");
        require(_price > 0, "INVALID_PRICE");

        _tokenPrice[_token] = _price;
        emit TokenPriceUpdated(_token, _price);
    }

    function getTokenPrice(address _token) external view returns (uint256) {
        return _tokenPrice[_token];
    }

    function withdrawERC20(IERC20 token, address to, uint256 amount) external onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "INSUFFICIENT_BALANCE");
        token.safeTransfer(to, amount);
    }

    function withdrawNative(address payable to, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "INSUFFICIENT_BALANCE");
        (bool success, ) = to.call{value: amount}("");
        require(success, "TRANSFER_FAILED");
    }
}
