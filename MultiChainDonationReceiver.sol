// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract MultiChainDonationReceiver is Ownable {
    // Mapping to store token addresses for different chains
    mapping(string => address) public usdtAddresses;
    mapping(string => address) public usdcAddresses;

    // Address where funds are received
    address public recipient;

    // Events to track donations
    event EthDonationReceived(address indexed donor, uint amount);
    event TokenDonationReceived(address indexed donor, uint amount, string tokenType, string chain);

    constructor(address initialOwner) Ownable(initialOwner) {
        // Set the recipient address with checksum
        recipient = 0x2699b2CB29eaf28FBaA8d8F2584D7c68F78BD087;

        // Initialize with correct addresses for each chain
        usdtAddresses["ethereum"] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        usdcAddresses["ethereum"] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        
        usdtAddresses["arbitrum"] = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
        usdcAddresses["arbitrum"] = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;

        usdtAddresses["optimism"] = 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58;
        usdcAddresses["optimism"] = 0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85;

        usdtAddresses["base"] = 0xfde4C96c8593536E31F229EA8f37b2ADa2699bb2;
        usdcAddresses["base"] = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

        usdtAddresses["scroll"] = 0xf55BEC9cafDbE8730f096Aa55dad6D22d44099Df;
        usdcAddresses["scroll"] = 0x06eFdBFf2a14a7c8E15944D1F4A48F9F95F663A4;
    }

    // Function to receive ETH donations
    receive() external payable {
        require(msg.value > 0, "Donation amount must be greater than zero");
        emit EthDonationReceived(msg.sender, msg.value);
        payable(recipient).transfer(msg.value);
    }

    // Function to donate USDT
    function donateUSDT(string memory chain, uint amount) external {
        require(amount > 0, "Donation amount must be greater than zero");
        address usdtAddress = usdtAddresses[chain];
        require(usdtAddress != address(0), "Unsupported chain");
        IERC20 usdt = IERC20(usdtAddress);
        
        require(usdt.transferFrom(msg.sender, recipient, amount), "USDT transfer failed");
        emit TokenDonationReceived(msg.sender, amount, "USDT", chain);
    }

    // Function to donate USDC
    function donateUSDC(string memory chain, uint amount) external {
        require(amount > 0, "Donation amount must be greater than zero");
        address usdcAddress = usdcAddresses[chain];
        require(usdcAddress != address(0), "Unsupported chain");
        IERC20 usdc = IERC20(usdcAddress);
        
        require(usdc.transferFrom(msg.sender, recipient, amount), "USDC transfer failed");
        emit TokenDonationReceived(msg.sender, amount, "USDC", chain);
    }

    // Function to update recipient address
    function setRecipient(address _recipient) external onlyOwner {
        require(_recipient != address(0), "Invalid address");
        recipient = _recipient;
    }

    // Function to update token addresses for a given chain
    function updateTokenAddresses(string memory chain, address usdtAddress, address usdcAddress) external onlyOwner {
        require(usdtAddress != address(0) && usdcAddress != address(0), "Invalid address");
        usdtAddresses[chain] = usdtAddress;
        usdcAddresses[chain] = usdcAddress;
    }
}
