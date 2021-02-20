require "jasper_helpers"

class ApplicationController < Amber::Controller::Base
  @@user_index = 0
  @@room_index = 0
  @@users = {} of String => User
  @@rooms = {} of String => Room
  @@subscribers = {} of String => Array(Amber::WebSockets::ClientSocket)

  def ApplicationController.subscribers
    @@subscribers
  end

  include JasperHelpers
  LAYOUT = "application.slang"
end
