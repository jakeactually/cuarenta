class SetupController < ApplicationController
    before_action do
        only [:play] do
            if HomeController.rooms[params[:room_id]]?.nil?
                halt!(404, "Room doesn't exists")
            end
        end
    end

    def play
        room = HomeController.rooms[params[:room_id]]
        player = HomeController.users[session[:player_id]]

        players_amount = room.players_list.size
        is_room_valid = players_amount == 2 || players_amount == 4
        
        if !is_room_valid
            halt!(400)
            return "There must be 2 or 4 players"
        end

        if !room.active
            shuffle(room)
        end

        room.update_player
        Game.new(room, player).to_json
    end

    def shuffle(room : Room)
        if room.deck.size == 0
            room.deck = Card.all.shuffle
        end

        room.players.each { |player|
            hand, room.deck = room.deck[0..4], room.deck[5..]
            player.hand = Set.new(hand)
        }
        room.active = true
    end

    def notify(room_id : String)
        subscribers = Amber::WebSockets::ClientSockets
            .get_subscribers_for_topic("cuarenta_room:#{room_id}")
        msg = {
            "topic" => "cuarenta_room:#{room_id}",
            "subject" => "message_new",
            "payload" => ""
        }
        subscribers.each_value(&.socket.send(msg.to_json))
    end
    
    def sum(room : Room, player : User, turn : Turn)
        if room.dirty
            halt!(400)
            return "You already threw a card"
        end

        room.dirty = true
        hand = turn.hand

        if turn.board.size == 0
            if hand
                player.hand.delete(hand)
                room.board.add(hand)
            end
        else
            if hand.try(&.value) != turn.board.map(&.value.to_i).sum
                halt!(400)
                return "Those cards don't add up"
            end

            player.hand.delete(turn.hand)
            room.board -= turn.board
            player.card_points += turn.board.size + 1

            if hand
                if hand.value == room.last_card.value
                    player.points += 2
                end
            end

            if room.board.size == 0
                player.points += 2
            end
        end

        room.claim = Set(Card).new

        if hand
            ((hand.chain_value + 1)..).each { |i|
                next_cards = room.board.select { |card| card.chain_value == i }
                break if next_cards.size == 0
                room.claim += Set.new(next_cards)
            }
        end
    end

    def pass(room : Room, player : User, turn : Turn)
        if !room.dirty
            halt!(400)
            return "You haven't throw a card"
        end

        room.next_turn
        room.dirty = false
        
        if room.players.all?(&.hand.size.zero?)
            shuffle(room)
        end
    end

    def claim(room : Room, player : User, turn : Turn)
        if room.claim.size == 0
            halt!(400)
            return "There is nothing to claim"
        end

        if !room.claim.superset?(turn.board)
            halt!(400)
            return "You can't claim those cards"
        end

        player.card_points += room.claim.size
        room.claim = Set(Card).new
        room.board -= turn.board
        
        if room.board.size == 0
            player.points += 2
        end
    end

    def turn
        room = HomeController.rooms[params[:room_id]]
        player = HomeController.users[session[:player_id]]

        if !room.active
            halt!(400)
            return "Room isn't active"
        end

        if room.current_player != player
            halt!(401)
            return "It's not your turn"
        end
        
        turn = Turn.from_json request.body.try(&.gets_to_end) || ""

        res = if turn.action == "sum"
            sum(room, player, turn)
        elsif turn.action == "pass"
            pass(room, player, turn)
        elsif turn.action == "claim"
            claim(room, player, turn)
        end

        hand = turn.hand
        if hand
            room.last_card = hand
        end

        notify(params[:room_id])

        return res
    end
end
