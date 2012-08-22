require "active_record"

Dir["./**/*.rb"].each { |f| require f }

module Listlace
  extend self

  PROMPT = [proc { ">> " }, proc { " | " }]
end
