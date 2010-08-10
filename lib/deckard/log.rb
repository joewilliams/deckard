class Deckard
  class Log
    extend Mixlib::Log
    log_file = Deckard::Config.log_file

    if log_file
      Deckard::Log.init(log_file)
    end
    Deckard::Log.level(:info)
  end
end
