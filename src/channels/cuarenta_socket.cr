struct CuarentaSocket < Amber::WebSockets::ClientSocket
    channel "cuarenta_room:*", CuarentaChannel

    def on_connect
        true
    end
end
