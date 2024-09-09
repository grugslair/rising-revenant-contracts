use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct ERC721TotalSupplyModel {
    #[key]
    token: ContractAddress,
    total_supply: u128,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct ERC721OwnerModel {
    #[key]
    token: ContractAddress,
    #[key]
    token_id_high: u128,
    #[key]
    token_id_low: u128,
    address: ContractAddress
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct ERC721BalanceModel {
    #[key]
    token: ContractAddress,
    #[key]
    account: ContractAddress,
    amount: u128,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct ERC721TokenApprovalModel {
    #[key]
    token: ContractAddress,
    #[key]
    token_id_high: u128,
    #[key]
    token_id_low: u128,
    address: ContractAddress,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct ERC721OperatorApprovalModel {
    #[key]
    token: ContractAddress,
    #[key]
    owner: ContractAddress,
    #[key]
    operator: ContractAddress,
    approved: bool
}


#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct ERC721EnumerableIndexModel {
    #[key]
    token: ContractAddress,
    #[key]
    index: u128,
    token_id: u256,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct ERC721EnumerableTokenModel {
    #[key]
    token: ContractAddress,
    #[key]
    token_id_high: u128,
    #[key]
    token_id_low: u128,
    index: u128,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct ERC721EnumerableOwnerIndexModel {
    #[key]
    token: ContractAddress,
    #[key]
    owner: ContractAddress,
    #[key]
    index: u128,
    token_id: u256,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct ERC721EnumerableOwnerTokenModel {
    #[key]
    token: ContractAddress,
    #[key]
    owner: ContractAddress,
    #[key]
    token_id_high: u128,
    #[key]
    token_id_low: u128,
    index: u128,
}


#[generate_trait]
impl ERC721ReadImpl of ERC721Read {
    fn get_total_supply(self: @IWorldDispatcher, token: ContractAddress) -> u128 {
        ERC721TotalSupplyModelStore::get_total_supply(*self, token)
    }

    fn get_balance(
        self: @IWorldDispatcher, token: ContractAddress, account: ContractAddress
    ) -> u128 {
        ERC721BalanceModelStore::get_amount(*self, token, account)
    }

    fn get_owner(
        self: @IWorldDispatcher, token: ContractAddress, token_id: u256
    ) -> ContractAddress {
        ERC721OwnerModelStore::get_address(*self, token, token_id.high, token_id.low)
    }

    fn get_approval(
        self: @IWorldDispatcher, token: ContractAddress, token_id: u256
    ) -> ContractAddress {
        ERC721TokenApprovalModelStore::get_address(*self, token, token_id.high, token_id.low)
    }

    fn get_approval_for_all(
        self: @IWorldDispatcher,
        token: ContractAddress,
        owner: ContractAddress,
        operator: ContractAddress
    ) -> bool {
        ERC721OperatorApprovalModelStore::get_approved(*self, token, owner, operator)
    }

    fn get_id_from_index(self: @IWorldDispatcher, token: ContractAddress, index: u128) -> u256 {
        ERC721EnumerableIndexModelStore::get_token_id(*self, token, index)
    }

    fn get_index_from_id(self: @IWorldDispatcher, token: ContractAddress, token_id: u256) -> u128 {
        ERC721EnumerableTokenModelStore::get_index(*self, token, token_id.high, token_id.low)
    }
    fn get_id_from_owner_index(
        self: @IWorldDispatcher, token: ContractAddress, owner: ContractAddress, index: u128
    ) -> u256 {
        ERC721EnumerableOwnerIndexModelStore::get_token_id(*self, token, owner, index)
    }

    fn get_owner_index_from_id(
        self: @IWorldDispatcher, token: ContractAddress, owner: ContractAddress, token_id: u256
    ) -> u128 {
        ERC721EnumerableOwnerTokenModelStore::get_index(
            *self, token, owner, token_id.high, token_id.low
        )
    }
}

#[generate_trait]
impl ERC721WriteImpl of ERC721Write {
    fn set_total_supply(self: IWorldDispatcher, token: ContractAddress, total_supply: u128) {
        ERC721TotalSupplyModel { token, total_supply, }.set(self);
    }

    fn set_balance(
        self: IWorldDispatcher, token: ContractAddress, account: ContractAddress, amount: u128
    ) {
        ERC721BalanceModel { token, account, amount, }.set(self);
    }

    fn set_owner(
        self: IWorldDispatcher, token: ContractAddress, token_id: u256, address: ContractAddress
    ) {
        ERC721OwnerModel {
            token, token_id_high: token_id.high, token_id_low: token_id.low, address
        }
            .set(self);
    }

    fn set_approval(
        self: IWorldDispatcher, token: ContractAddress, token_id: u256, address: ContractAddress
    ) {
        ERC721TokenApprovalModel {
            token, token_id_high: token_id.high, token_id_low: token_id.low, address
        }
            .set(self);
    }

    fn set_approval_for_all(
        self: IWorldDispatcher,
        token: ContractAddress,
        owner: ContractAddress,
        operator: ContractAddress,
        approved: bool
    ) {
        ERC721OperatorApprovalModel { token, owner, operator, approved }.set(self);
    }

    fn set_id_from_index(
        self: IWorldDispatcher, token: ContractAddress, index: u128, token_id: u256
    ) {
        ERC721EnumerableIndexModel { token, index, token_id }.set(self);
    }

    fn set_index_from_id(
        self: IWorldDispatcher, token: ContractAddress, token_id: u256, index: u128
    ) {
        ERC721EnumerableTokenModel {
            token, token_id_high: token_id.high, token_id_low: token_id.low, index,
        }
            .set(self);
    }

    fn set_id_from_owner_index(
        self: IWorldDispatcher,
        token: ContractAddress,
        owner: ContractAddress,
        index: u128,
        token_id: u256
    ) {
        ERC721EnumerableOwnerIndexModel { token, owner, index, token_id }.set(self);
    }

    fn set_owner_index_from_id(
        self: IWorldDispatcher,
        token: ContractAddress,
        owner: ContractAddress,
        token_id: u256,
        index: u128
    ) {
        ERC721EnumerableOwnerTokenModel {
            token, owner, token_id_high: token_id.high, token_id_low: token_id.low, index,
        }
            .set(self);
    }
}
