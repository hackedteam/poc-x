# TODO: define a custom backend that inherits from This::Backend::Base
module Thin
  module Backends
    class Base
      def stop!
        @running  = false
        @stopping = false

        EventMachine.stop
        @connections.each_value { |connection| connection.close_connection }
        close
        exit!(0)
      end
    end
  end
end
