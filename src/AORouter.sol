// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AORouter is Ownable, Pausable {
    using SafeERC20 for IERC20;

    uint256 public agentFee = 10; // Default: 0.1% (in BPS)

    // Events
    event AgentFeeUpdated(uint256 newFee);
    event SwapCompleted(address indexed user, address indexed tokenToReceive, uint256 amountAfterFee);

    constructor() Ownable(msg.sender) {}

    receive() external payable {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setAgentFee(uint256 _newFee) external onlyOwner {
        agentFee = _newFee;
        emit AgentFeeUpdated(_newFee);
    }

    function aoSwap(
        address _swapRouter,
        address _token,
        address[] memory _agentAddress,
        bytes calldata _data,
        uint256 _quotedTokenAmount
    ) external payable whenNotPaused {
        require(_agentAddress.length > 0, "NO_AGENTS_PROVIDED");
        require(msg.value > 0, "INVALID_NATIVE_AMOUNT");
        require(_token != address(0), "INVALID_TOKEN_TO_RECEIVE");

        uint256 totalFee = (msg.value * agentFee) / 10_000; // BPS calculation
        uint256 feePerAgent = totalFee / _agentAddress.length; // Distribute evenly
        uint256 remainingAmount = msg.value - totalFee; // Amount sent to Pool contract

        // Distribute fee
        for (uint256 i = 0; i < _agentAddress.length; i++) {
            (bool successFee, ) = payable(_agentAddress[i]).call{value: feePerAgent}("");
            require(successFee, "AGENT_TRANSFER_FAILED");
        }

        (bool success, ) = _swapRouter.call{value: remainingAmount, gas: 500000}(_data);
        require(success, "SWAP_FAILED");

        IERC20(_token).transfer(msg.sender, _quotedTokenAmount);
        
        emit SwapCompleted(msg.sender, _token, remainingAmount);
    }

    function withdrawETH(address _receiver) external onlyOwner {
        (bool success, ) = payable(_receiver).call{value: address(this).balance}("");
        require(success, "WITHDRAW_FAILED");     
    }

    function withdrawERC20(address _token, address _receiver) external onlyOwner {
        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(_receiver, balance);
    }
}
