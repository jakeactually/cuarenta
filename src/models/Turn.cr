class Turn
    JSON.mapping(
        action: String,
        board: Set(Card),
        hand: Card,
    )
end
