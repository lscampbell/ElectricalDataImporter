require_relative 'mpan_cache'
require 'date'

# Import the one line hybrid format
class SingleLineHybridImporter
  def initialize(publisher, meta)
    @mpan_column        = meta[:mpan]
    @date_column        = meta[:date]
    @measurement_column = meta[:measurement]
    @readings_columns   = meta[:readings]
    @estimated_flags    = meta[:estimated_flags]
    @header_row         = meta[:header_row]
    @date_format        = meta[:date_format] || '%d/%m/%Y'
    @mpan_cache         = MpanCache.new(publisher)
  end

  def import(input)
    input.each do |row|
      parse_row(row)
    end
    @mpan_cache.flush
  end

  def header_row?
    @header_row
  end

  def parse_row(row)
    return if row.empty?
    date, mpan_day = initialize_variables(row)
    populate_consumption_data(date, mpan_day, row)
    populate_lag_or_lead(mpan_day, row[@readings_columns[1]], :lag)
    populate_lag_or_lead(mpan_day, row[@readings_columns[2]], :lead)
  end

  def initialize_variables(row)
    mpan     = row[@mpan_column]
    date     = DateTime.strptime(row[@date_column], @date_format)
    mpan_day = @mpan_cache.get_mpan_day(mpan, date)
    [date, mpan_day]
  end

  def populate_consumption_data(date, mpan_day, values)
    data_points     = create_data_points(date, values[@readings_columns[0]])
    mpan_day[:data] = data_points
  end

  def populate_lag_or_lead(mpan_day, readings, key)
    lag_values = @estimated_flags ? readings.each_slice(2).map(&:first).to_a : readings
    lag_values.each_with_index do |value, index|
      mpan_day[:data][index][key] = value ? value.to_f : nil
    end
  end

  def create_data_points(date, readings)
    result      = []
    data_points = @estimated_flags ? readings.each_slice(2).to_a : readings.map { |r| [r] }
    data_points.each_with_index do |array, index|
      merge_in_data_points(array, date, index, result)
    end
    result
  end

  def merge_in_data_points(array, date, index, result)
    estimated_hash = @estimated_flags ? { estimated: array[1].nil? || array[1].lstrip.chomp != 'A' } : {}
    result << { kwh: array[0] ? array[0].to_f : nil }.merge(get_start_and_end(date, index)).merge(estimated_hash)
  end

  def get_start_and_end(date, index)
    { start: date + Rational(index, 48), end: date + Rational(index + 1, 48) }
  end
end