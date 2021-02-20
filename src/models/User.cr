class User
    JSON.mapping(
        id: UInt64,
        name: String,
        hand: Set(Card),
    )

    def initialize(@name : String, @id : UInt64)
        @hand = Set(Card).new
    end

    def ==(other : User)
        self.id == other.id
    end

    def hash
        self.id
    end
end
