# Blockchain
Smart Contract to erase Re-entrancy attack
Explanation of Design Choices to Prevent Re-Entrancy
1. Checks-Effects-Interactions Pattern:
   - The withdraw  function follows the checks-effects-interactions pattern, which is a key defensive coding technique in Solidity:
     - Checks: The contract first checks if the caller (msg.sender) has a sufficient balance by comparing balances[msg.sender] with amount. If they don't, it reverts with a custom error, balanceTooLow.
     - Effects: If the check passes, the contract updates the state by deducting the withdrawal amount  from balances[msg.sender]. This change is applied before any Ether is transferred, which effectively "locks" the user's balance and prevents them from trying to withdraw the same amount multiple times.
     
- Interactions: Finally, after updating the state, the contract makes an external call using (msg.sender).call{value: amount}("") to transfer Ether to the user. By placing this call at the end, the contract minimizes the risk of re-entrancy because the user’s balance has already been updated to reflect the deduction.

2. State Update Before External Call:
   - The contract updates balances[msg.sender] -= amount before transferring any Ether to the user. This prevents re-entrancy because if msg.sender  attempts to re-enter the contract (i.e., call withdraw recursively during the external call), their balance will already reflect the deduction. Consequently, any additional withdrawal attempts will fail due to insufficient funds.

3. Use of call for Ether Transfer:
   - Using (msg.sender).call{value: amount}("") provides full control over the gas allocation for the external call, allowing the contract to handle failed transfers gracefully. Additionally, it avoids potential issues with transfer and send, which have fixed gas stipends and may not work in certain edge cases.
   - The contract also checks the success of the transfer with if(!sent) revert transferFailed(); , ensuring that any failed transfer reverts the transaction to maintain the integrity of the contract’s state.

4. Custom Errors for Efficiency:
   - The contract uses custom errors (noValueSent and balanceTooLow) for more efficient error handling. These errors provide specific feedback without using extensive revert strings, which can reduce gas costs.

Summary

By following these design principles, the CA2 contract effectively prevents re-entrancy attacks. The primary defense is in the checks-effects-interactions pattern and updating state before external calls, which ensures that recursive calls cannot exploit the withdraw() function to drain the contract’s funds. This structure is essential for secure contract design in Solidity.


