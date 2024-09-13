struct Outpost{
    #[key]
    game_id: u128,
    #[key]
    outpost_id: u128,
    position: Point,
    fortifications: Fortifications,
    hp: u128,
}