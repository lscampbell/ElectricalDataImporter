require 'date'
require_relative 'mpan_cache'

# This import both deals with imported and export energy
class SingleLineImportExportImporter
  def initialize(publisher, meta)
    @mpan_column      = meta[:mpan]
    @date_column      = meta[:date]
    @measurement_flag = meta[:measurement]
    @readings_columns = meta[:readings]
    @estimated_flags  = meta[:estimated_flags]
    @header_row       = meta[:header_row]
    @date_format      = meta[:date_format] || '%d/%m/%Y'
    @mpan_cache       = MpanCache.new(publisher)
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
    return unless row[@measurement_flag] == 'AI'
    mpan     = row[@mpan_column]
    date     = DateTime.strptime(row[@date_column], @date_format)
    mpan_day = @mpan_cache.get_mpan_day(mpan, date)

    populate_consumption_data(date, mpan_day, row)
  end

  def populate_consumption_data(date, mpan_day, values)
    data_points     = create_data_points(date, values[@readings_columns])
    mpan_day[:data] = data_points
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