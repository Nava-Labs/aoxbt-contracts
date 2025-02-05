// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

interface IPool {
    function swap(address _recipient, address _token) external payable;
}

contract AgentRouter is Ownable, Pausable {
    uint256 public agentFee = 10; // Default: 0.1% (in BPS)
    address public poolContract; // Address of the Pool contract

    // Events
    event AgentFeeUpdated(uint256 newFee);
    event SwapCompleted(address indexed user, address indexed tokenToReceive, uint256 amountAfterFee);
    event PoolContractUpdated(address indexed newPool);

    constructor(address _poolContract) Ownable(msg.sender) {
        require(_poolContract != address(0), "INVALID_POOL_ADDRESS");
        poolContract = _poolContract;
    }

    receive() external payable {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setPoolContract(address _newPool) external onlyOwner {
        require(_newPool != address(0), "INVALID_POOL_ADDRESS");
        poolContract = _newPool;
        emit PoolContractUpdated(_newPool);
    }

    function setAgentFee(uint256 _newFee) external onlyOwner {
        require(_newFee > 10, "FEE_TOO_LOW"); // Must be greater than 0.1% (10 BPS)
        agentFee = _newFee;
        emit AgentFeeUpdated(_newFee);
    }

    function swap(
        address[] memory _agentAddress,
        address _tokenToReceive
    ) external payable whenNotPaused {
        require(_agentAddress.length > 0, "NO_AGENTS_PROVIDED");
        require(msg.value > 0, "INVALID_NATIVE_AMOUNT");
        require(_tokenToReceive != address(0), "INVALID_TOKEN_TO_RECEIVE");

        uint256 totalFee = (msg.value * agentFee) / 10_000; // BPS calculation
        uint256 feePerAgent = totalFee / _agentAddress.length; // Distribute evenly
        uint256 remainingAmount = msg.value - totalFee; // Amount sent to Pool contract

        require(feePerAgent > 0, "FEE_TOO_SMALL");

        // Distribute fee
        for (uint256 i = 0; i < _agentAddress.length; i++) {
            (bool success, ) = payable(_agentAddress[i]).call{value: feePerAgent}("");
            require(success, "AGENT_TRANSFER_FAILED");
        }

        // Send remaining ETH to the Pool
        IPool(poolContract).swap{value: remainingAmount}(msg.sender, _tokenToReceive);

        emit SwapCompleted(msg.sender, _tokenToReceive, remainingAmount);
    }
}
