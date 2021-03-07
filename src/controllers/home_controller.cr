class HomeController < ApplicationController
  before_action do
    only [:room, :join_room] do
      if @@rooms[params[:room_id]]?.nil?
        halt!(404, "Room doesn't exists")
      end
    end
  end

  def HomeController.rooms
    @@rooms
  end
  
  def HomeController.users
    @@users
  end

  def get_user
    player_id = session[:player_id]

    if player_id.nil?
      @@user_index += 1
      player_id = @@user_index.to_s
      session[:player_id] = player_id
    end

    if @@users[player_id]?.nil?
      @@users[player_id] = User.new(params[:username], player_id.to_u64)
    end

    @@users[player_id]
  end
 
  def index
    user = @@users[session[:player_id]]? || User.new("", 0)
    user.to_json
  end

  def new_room
    @@room_index += 1
    @@rooms[@@room_index.to_s] = Room.new.push(get_user)
    { "room_id" => @@room_index }.to_json
  end

  def room
    player_id = session[:player_id]
    room = @@rooms[params[:room_id]]
    halt!(401, "Player not in room") if @@users[player_id]?.nil? || !room.includes?((player_id || 0).to_u64)
    room.to_json
  end

  def join_room
    room_id = params[:room_id]
    @@rooms[room_id].push(get_user)

    subscribers = Amber::WebSockets::ClientSockets
      .get_subscribers_for_topic("cuarenta_room:#{room_id}")
    msg = { "topic" => "cuarenta_room:#{room_id}", "subject" => "message_new", "payload" => "" }
    subscribers.each_value(&.socket.send(msg.to_json))

    { "room_id" => @@room_index }.to_json
  end
end
