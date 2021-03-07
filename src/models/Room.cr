class Room
    JSON.mapping(
        players: Set(User),
        deck: Array(Card),
        board: Set(Card),
        current_player: User
    )

    property active = false
    property players_list = [] of User
    property turn = 0
    property dirty = false
    property claim = Set(Card).new
    property last_card = Card.new(0, "", "", "")

    def initialize
        @players = Set(User).new
        @deck = [] of Card
        @board = Set(Card).new
        @current_player = User.new("", 0)
    end

    def update_player
        @current_player = @players_list[@turn % @players_list.size]
    end

    def next_turn
        @turn += 1
        update_player
    end

    def push(user : User)
        @players.add(user)
        @players_list.push(user)
        self
    end

    def includes?(id : UInt64)
        @players.includes?(User.new("", id))
    end
end
