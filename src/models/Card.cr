class Card
    @@all : Array(Card) = ["A", "2", "3", "4", "5", "6", "7", "J", "Q", "K"]
        .map_with_index { |number, i|
        ["C", "D", "H", "S"].map_with_index { |sign, j|
            Card.new((i * 4 + j).to_u64, "#{number}#{sign}", number, sign)
        }
    }.flatten

    JSON.mapping(
        id: UInt64,
        name: String,
        number: String,
        sign: String
    )

    @@values = {
        "A" => 1,
        "2" => 2,
        "3" => 3,
        "4" => 4,
        "5" => 5,
        "6" => 6,
        "7" => 7,
        "J" => 11,
        "Q" => 12,
        "K" => 13 
    }

    @@chain_values = {
        "A" => 1,
        "2" => 2,
        "3" => 3,
        "4" => 4,
        "5" => 5,
        "6" => 6,
        "7" => 7,
        "J" => 8,
        "Q" => 9,
        "K" => 10 
    }

    def initialize(@id : UInt64, @name : String, @number : String, @sign : String)
    end

    def value
        @@values[@number]
    end

    def chain_value
        @@chain_values[@number]
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
