require 'icalendar'

SCHEDULER.every '5m', :first_in => 0 do |job|
  config_file = 'config/calendars.yml'
  config = YAML.load_file(config_file)
  
  events_by_calendar = {}
  
  config['calendars'].each do |key, cal|
    result = Net::HTTP.get URI cal['url']
    calendars = Icalendar::Calendar.parse(result)

    events = calendars.first.events.map do |event|
      {
        start: event.dtstart,
        end: event.dtend,
        summary: event.summary,
        location: event.location
      }
    end

    if cal.has_key? 'exclusions'
      exclusions = cal['exclusions'].map { |name| name.downcase }
      events.reject! do |event| 
        exclusions.include?(event[:summary].downcase)
      end
    end

    events.select! do |event|
      time = event[:end] || event[:start]
      time > DateTime.now
    end

    events = events.sort { |a, b| a[:start] <=> b[:start] }

    if cal.has_key? 'limit'
      events = events[0..cal['limit']]
    end

    send_event "calendar-#{key}", {
      name: cal['name'],
      events: events
    }
  end
end
