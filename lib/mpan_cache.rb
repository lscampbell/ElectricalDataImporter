# Mpan cache used as day container store for mpan
class MpanCache
  def initialize(publisher)
    @publisher = publisher
    @cache = {}
  end

  def get_mpan_day(mpan, date)
    create_new_mpan(mpan) unless @current_mpan == mpan
    @cache[date] ||= { mpan: mpan, date: date }
  end

  def create_new_mpan(mpan)
    post_current_mpan unless @current_mpan.nil?
    @cache = {}
    @current_mpan = mpan
  end

  def post_current_mpan
    @publisher.publish(@cache.values)
  end

  def flush
    post_current_mpan
    @cache == {}
  end
end