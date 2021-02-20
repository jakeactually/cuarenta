class Room
    JSON.mapping(
        players: Set(User),
        deck: Array(Card),
        board: Set(Card)
    )

    property active = false

    def initialize
        @players = Set(User).new
        @deck = [] of Card
        @board = Set(Card).new
    end

    def push(user : User)
        @players.add(user)
        self
    end

    def includes?(id : UInt64)
        @players.includes?(User.new("", id))
    end
end
