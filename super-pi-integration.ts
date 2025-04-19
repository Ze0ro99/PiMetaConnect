import { Blockchain, Transaction } from 'super-pi';

// Initialize the blockchain
const piMetaBlockchain = new Blockchain();

// Add a new transaction
const transaction = new Transaction(
  senderAddress,
  receiverAddress,
  amount
);
piMetaBlockchain.addTransaction(transaction);

// Verify transactions
if (piMetaBlockchain.verifyTransaction(transaction)) {
  console.log('Transaction verified and added to the blockchain.');
}

// Export blockchain instance for PiMetaConnect
export default piMetaBlockchain;
