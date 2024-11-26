address 0x6edbe203716b31cdd270e632649476c4495fba6f86238632a525fbd7a9702ded {
    module WalletManager {

        use std::signer;
        
        struct Wallet has store {
            balance: u64,
            threshold: u64,
            is_open: bool,
            owner: address,
        }

        /// Initializes a wallet for a given owner d123 threshold.
        public fun initialize(wallet_owner: address, threshold: u64): Wallet {
            Wallet {
                balance: 0,
                threshold: threshold,
                is_open: true,
                owner: wallet_owner,
            }
        }

        /// Deposits an amount into the wallet. Closes the wallet if the balance exceeds the threshold.
        public fun deposit(wallet: &mut Wallet, amount: u64) {
            assert!(wallet.is_open, 100); // 100: Wallet is closed.
            assert!(amount <= (0xFFFFFFFFFFFFFFFF - wallet.balance), 103); // 103: Overflow error.
            wallet.balance = wallet.balance + amount;

            // Automatically close wallet when balance exceeds threshold
            if (wallet.balance >= wallet.threshold) {
                wallet.is_open = false;
            }
        }

        /// Withdraws an amount from the wallet, ensuring only the owner can do so.
        public fun withdraw(wallet: &mut Wallet, amount: u64, signer: &signer) {
            assert!(wallet.is_open, 100); // 100: Wallet is closed.
            assert!(wallet.owner == signer::address_of(signer), 101); // 101: Unauthorized access.
            assert!(wallet.balance >= amount, 102); // 102: Insufficient balance.
            wallet.balance = wallet.balance - amount;
        }

        /// Returns the current balance of the wallet.
        public fun get_balance(wallet: &Wallet): u64 {
            wallet.balance
        }

        /// Checks if the wallet is open.
        public fun is_wallet_open(wallet: &Wallet): bool {
            wallet.is_open
        }
    }
}
