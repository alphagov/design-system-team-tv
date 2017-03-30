class Dashing.GoogleCalendar extends Dashing.Widget

  onData: (data) =>
    events = []
    calendar_classes = {}

    for event in data.events
      start = moment(event.start)
      end = moment(event.end)

      isAllDayEvent = [
        start.hour(),
        start.minute(),
        end.hour(),
        end.minute()
      ].every (x)-> x == 0

      isMultipleDayEvent = start.format('DMYY') != end.format('DMYY')

      events.push {
        summary: event.summary,
        location: event.location,
        start_date: start.format('dddd Do MMMM'),
        start_time: start.format('HH:mm'),
        end_date: end.format('dddd Do MMMM'),
        end_time: end.format('HH:mm'),
        is_multiple_day: isMultipleDayEvent,
        is_all_day: isAllDayEvent,
        is_ranged: !isAllDayEvent || isMultipleDayEvent
      }

    @set('events', events)
    @set('name', data.name)
