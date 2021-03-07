class User
    JSON.mapping(
        id: UInt64,
        name: String,
        hand: Set(Card),
        points: Int32,
        card_points: Int32,
    )

    def initialize(@name : String, @id : UInt64)
        @hand = Set(Card).new
        @points = 0
        @card_points = 0
    end

    def ==(other : User)
        self.id == other.id
    end

    def hash
        self.id
    end
end
