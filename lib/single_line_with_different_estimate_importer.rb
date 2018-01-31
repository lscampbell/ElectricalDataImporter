require_relative 'mpan_cache'
require 'date'

# Import the one line file format
class SingleLineWithDifferentEstimateImporter
  def initialize(publisher, meta)
    @mpan_column        = meta[:mpan]
    @date_column        = meta[:date]
    @measurement_column = meta[:measurement]
    @readings_columns   = meta[:readings]
    @estimated_flags    = meta[:estimated_flags]
    @header_row         = meta[:header_row]
    @date_format        = meta[:date_format] || '%d/%m/%Y'
    @actual             = 'A'
    @skip_flag          = 'X'
    @energy_measure     = 'KVARH'
    @mpan_cache         = MpanCache.new(publisher)
  end

  def import(input)
    input.each do |l|
      parse_row(l)
    end
    @mpan_cache.flush
  end

  def header_row?
    @header_row
  end

  def parse_row(row)
    return if row.empty?
    if @estimated_flags.is_a? Range
      return if row[@estimated_flags].all? { |flag| flag == @skip_flag }
      return if row[@measurement_column] == @energy_measure
    end
    return if row[@readings_columns].all?(&:nil?)
    mpan     = row[@mpan_column]
    date     = DateTime.strptime(row[@date_column], @date_format)
    mpan_day = @mpan_cache.get_mpan_day(mpan, date)

    populate_consumption_data(date, mpan_day, row)
  end

  def populate_consumption_data(date, mpan_day, values)
    data_points     = create_data_points(date, values[@readings_columns], values)
    mpan_day[:data] = data_points
  end

  def create_data_points(date, readings, values)
    result      = []
    data_points = readings.map { |r| [r] }

    if @estimated_flags.is_a? Numeric
      data_points = merge_in_the_estimates(values, data_points, false)
    end
    if @estimated_flags.is_a? Range
      data_points = merge_in_the_estimates(values, data_points, true)
      @actual     = 'N'
    end
    data_points.each_with_index do |array, index|
      merge_in_data_points(array, date, index, result)
    end
    result
  end

  def merge_in_the_estimates(values, data_points, range_or_one_column, index = 0)
    data_points.each do |v|
      v.push range_or_one_column ? values[@estimated_flags.first + index] : values[@estimated_flags][index]
      index += 1
    end
    data_points
  end

  def merge_in_data_points(array, date, index, result)
    estimated_hash = @estimated_flags ? { estimated: array[1].nil? || array[1].lstrip.chomp != @actual } : {}
    result << { kwh: array[0] ? array[0].to_f : nil }.merge(get_start_and_end(date, index)).merge(estimated_hash)
  end

  def get_start_and_end(date, index)
    { start: date + Rational(index, 48), end: date + Rational(index + 1, 48) }
  end
end
