mod random;
mod felt252traits;
use starknet::{get_block_info, get_tx_info};


fn get_block_number() -> u64 {
    get_block_info().unbox().block_number
}


fn get_transaction_hash() -> felt252 {
    get_tx_info().unbox().transaction_hash
}
