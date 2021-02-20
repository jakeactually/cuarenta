class Game
    JSON.mapping(
        room: Room,
        user: User
    )

    def initialize(@room : Room, @user : User)
    end
end
