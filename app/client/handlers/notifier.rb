module Handlers
  class Notifier
    def initialize
      @subscribers = Hash.new { |h, k| h[k] = [] }
      @events = Hash.new { |h, k| h[k] = [] }
    end

    def subscribe(observer, name, method=nil, &block)
      raise "Error: requires either method or block" if !method && !block
      @subscribers[observer] << name
      @events[name] << { observer: observer, method: method, block: block }
    end

    def unsubscribe(observer, name)
      remove_events(observer, name)
      @subscribers[observer].reject! { |event_name| event_name == name }
    end

    def unsubscribe_all(observer)
      @subscribers.delete(observer).each { |name| remove_events(observer, name) }
    end

    def publish(sender, name, data)
      @events[name].each do |event|
        if method = event[:method]
          event[:observer].send(method, data)
        else
          event[:block].call(sender, data)
        end
      end
    end

    private
    def remove_events(observer, name)
      @events[name].reject! { |event| event[:observer] == observer }
    end
  end

  DefaultNotifier = Notifier.new
end
