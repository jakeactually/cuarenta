class Card
    @@all : Array(Card) = ["A", "2", "3", "4", "5", "6", "7", "J", "Q", "K"]
        .map_with_index { |number, i|
        ["C", "D", "H", "S"].map_with_index { |sign, j|
            Card.new((i * 4 + j).to_u64, "#{number}#{sign}")
        }
    }.flatten

    JSON.mapping(
        id: UInt64,
        name: String
    )

    def initialize(@id : UInt64, @name : String)
    end

    def ==(other : Card)
        self.id == other.id
    end

    def hash
        self.id
    end

    def Card.all
        @@all
    end
end
