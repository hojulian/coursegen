require 'date'
require 'active_support'
require 'active_support/core_ext/numeric/time'

WEEKDAYS = { sunday: 0, monday: 1, tuesday: 2,
             wednesday: 3, thursday: 4, friday: 5, saturday: 6 }.freeze

# Calculate days on which each event occurs, based on the configuration info
class Scheduler
  attr_reader :start_time, :end_time, :start_times, :end_times, :event_start_times, :event_end_times

  def self.add_weeks(the_date, number)
    the_date.to_date + Integer(number) * 7
  end

  def setup_from_args(start: nil, weekdays: nil, number: nil, skips: [],
                      start_time: 0, end_time: 0, start_times: [], end_times: [])
    if start.nil?
      @start = nil
      return
    end
    convert_and_verify_arguments(start, weekdays, number,
                                 skips, start_time, end_time, start_times, end_times)
    @weekdays.sort!
    recalc_event_map
  end

  def setup_from_schedule_def(sdef)
    if sdef.nil?
      @start = nil
      return
    end

    setup_from_args(
      start: sdef.first_day,
      weekdays: sdef.weekdays,
      number: sdef.number,
      skips: sdef.skips,
      start_time: sdef.start_time,
      end_time: sdef.end_time,
      start_times: sdef.start_times,
      end_times: sdef.end_times
    )
  end

  def event_date_by_index(ind)
    null? ? nil : @event_dates[ind]
  end

  def null?
    @start_date.nil?
  end

  private

  def recalc_event_map
    return if null?

    @event_dates = []
    @event_start_times = []
    @event_end_times = []
    wkdy_of_start = @start_date.cwday
    wkday_index = @weekdays.find_index(wkdy_of_start)
    curr_event_date = @start_date
    @number.times do |_i|
      unless @skips.include? curr_event_date
        @event_dates << curr_event_date
        @event_start_times << @start_times[wkday_index]
        @event_end_times << @end_times[wkday_index]
      end
      if @weekdays.length == 1
        curr_event_date += 7
      elsif wkday_index < @weekdays.length - 1
        wkday_index += 1
        curr_event_date += @weekdays[wkday_index] - @weekdays[wkday_index - 1]
      elsif wkday_index == @weekdays.length - 1
        wkday_index = 0 # wrap
        curr_event_date += 7 + @weekdays.first - @weekdays.last
      end
    end
  end

  def convert_and_verify_arguments(start, weekdays, number, skips,
                                   start_time, end_time, start_times, end_times)
    @number = number + skips.length
    @start_date = string_to_date(start)
    @skips = begin
               skips.map { |d| string_to_date(d) }
             rescue StandardError
               raise(ArgumentError, 'Scheduler: Invalid skip date')
             end

    unless weekdays.all? { |wd| WEEKDAYS.include? wd }
      raise ArgumentError, 'Scheduler: invalid weekdays'
    end

    @weekdays = weekdays.map { |wd| WEEKDAYS[wd] }
    unless @weekdays.include? @start_date.cwday
      raise ArgumentError, 'Scheduler: Start date is not on one of the weekdays'
    end
    unless @skips.reduce(true) { |accum, skip| accum && @weekdays.include?(skip.cwday) }
      raise ArgumentError, 'Scheduler: Skip date is not on a valid weekday'
    end

    @start_time = begin
                    time_span_to_seconds(start_time)
                  rescue StandardError
                    raise(ArgumentError, "error converting start time. Use hh:mm: #{start_time} ")
                  end
    @end_time = begin
                  time_span_to_seconds(end_time)
                rescue StandardError
                  raise(ArgumentError, "error converting end time. Use hh:mm: #{end_time}")
                end
    @start_times = start_times.map { |x| time_span_to_seconds(x) }
    @end_times = end_times.map { |x| time_span_to_seconds(x) }
  end

  def string_to_date(string_date)
    Date.strptime(string_date, '%b-%d-%Y')
  rescue StandardError
    raise "string to date in scheduler.rb #{string_date}"
  end

  def strings_to_date_time(string_date, string_time)
    DateTime.strptime(string_date + ' ' + string_time, '%b-%d-%Y %H:%M')
  end

  def time_span_to_seconds(string_time)
    result = string_time.match(/(\d\d):(\d\d)/)
    result[1].to_i.hours + result[2].to_i.minutes
  end
end
