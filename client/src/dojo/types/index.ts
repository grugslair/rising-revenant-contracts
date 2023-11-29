import { Account, num } from "starknet";

export interface SystemSigner {
    account: Account
}

export interface CreateGameProps extends SystemSigner {
    preparation_phase_interval: num.BigNumberish;
    event_interval: num.BigNumberish;
    erc_addr: num.BigNumberish;
}

export interface CreateRevenantProps extends SystemSigner {
    game_id: num.BigNumberish;
    name: num.BigNumberish;
}

export interface PurchaseReinforcementProps extends SystemSigner {
    game_id: num.BigNumberish;
    count: num.BigNumberish;
}

export interface ReinforceOutpostProps extends SystemSigner {
    game_id: num.BigNumberish;
    outpost_id: num.BigNumberish;
}

export interface CreateEventProps extends SystemSigner {
    game_id: num.BigNumberish;
}

export interface ConfirmEventOutpost extends SystemSigner {
    game_id: num.BigNumberish;
    event_id: num.BigNumberish;
    outpost_id: num.BigNumberish;
}
