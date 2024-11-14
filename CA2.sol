// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract CA2 {
    mapping(address => uint256) private balances;

    // Deposit event for logging purposes
    event Deposit(address indexed user, uint256 amount);
    // Withdrawal event for logging purposes
    event Withdraw(address indexed user, uint256 amount);

    // error for zero deposit;
    error noValueSent();
    // error for amount withdrawing is greater than the balance deposited
    error balanceTooLow(uint256 balance);
    // error for failed Transfer
    error transferFailed();

    // Deposit function allowing users to deposit Ether into the contract
    function deposit() external payable {
        if(msg.value < 0) revert noValueSent();      
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw function that follows checks-effects-interactions pattern
    function withdraw(uint256 amount) external {
        // **Checks** Check if the account has enough balance
        if(balances[msg.sender] < amount) revert balanceTooLow(balances[msg.sender]);

// **Effects:** Deduct the withdrawal amount from the user's balance first, done to prevent //Rentrency 
        balances[msg.sender] -= amount;

        // **Interactions:** Transfer Ether to the user only after updating state
        (bool sent, ) = msg.sender.call{value: amount}("");
        if(!sent) revert transferFailed();

        emit Withdraw(msg.sender, amount);
    }

    // Getter function to check the balance of a specific address
    function balanceOf(address user) external view returns (uint256) {
        return balances[user];
    }
}

