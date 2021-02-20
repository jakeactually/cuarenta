class SetupController < ApplicationController
    before_action do
        only [:play] do
        if HomeController.rooms[params[:room_id]]?.nil?
            halt!(404)
        end
        end
    end

    def play
        room = HomeController.rooms[params[:room_id]]
        player = HomeController.users[session[:player_id]]

        if !room.active
            cards = Card.all.shuffle
            room.players.each { |player|
                hand, cards = cards[0..4], cards[5..]
                player.hand = Set.new(hand)
            }
            room.deck = cards
            room.active = true
        end

        Game.new(room, player).to_json
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
    
    def turn
        room = HomeController.rooms[params[:room_id]]
        player = HomeController.users[session[:player_id]]

        halt!(505, "") if !room.active
        
        turn = Turn.from_json request.body.try(&.gets_to_end) || ""

        if turn.action == "sum"
            player.hand.delete(turn.hand)
            room.board.add(turn.hand)
        end
    end
end
