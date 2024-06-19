mod components {
    mod game;
    mod outpost;
    mod player;
    mod reinforcement;
    mod trade;
    mod world_event;
    mod currency;
}
mod constants;
mod contracts {
    mod game;
    mod outpost;
    mod payment;
    mod reinforcement;
    mod trade_reinforcement;
    mod trade_outpost;
    mod world_event;
}
mod defaults;
mod systems {
    mod get_set;
    mod game;
    mod outpost;
    mod player;
    mod trade;
    mod reinforcement;
    mod world_event;
    mod payment;
    mod position;
}

#[cfg(test)]
mod tests {
    mod test_contracts;
    mod reinforcement_test;
    mod utils;
    mod erc20;
}
mod utils;
