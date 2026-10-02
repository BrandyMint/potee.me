# Days off of a region: weekends plus public holidays, for dimming them on the
# board. Russia and its neighbours use official production calendars (with
# moved days off and working Saturdays, `rake potee:calendars`), other
# countries the `holidays` gem; a board without a region dims weekends only.
class WorkCalendar
  PRODUCTION = %w[RU BY KZ UZ].freeze
  REGIONS = %w[RU BY KZ UZ UA GE AM AZ KG RS ME CY TR IL AE TH DE AT CH FR ES IT NL PL PT CZ FI SE NO DK EE LV LT GB US CA AU].freeze
  WEEKENDS = { "IL" => [ 5, 6 ] }.freeze
  ZONES = {
    "Europe/Berlin" => "DE", "Europe/Vienna" => "AT", "Europe/Zurich" => "CH", "Europe/Paris" => "FR",
    "Europe/Madrid" => "ES", "Europe/Rome" => "IT", "Europe/Amsterdam" => "NL", "Europe/Warsaw" => "PL",
    "Europe/Lisbon" => "PT", "Europe/Prague" => "CZ", "Europe/Helsinki" => "FI", "Europe/Stockholm" => "SE",
    "Europe/Oslo" => "NO", "Europe/Copenhagen" => "DK", "Europe/Tallinn" => "EE", "Europe/Riga" => "LV",
    "Europe/Vilnius" => "LT", "Europe/London" => "GB", "Europe/Belgrade" => "RS", "Europe/Podgorica" => "ME",
    "Asia/Nicosia" => "CY", "Asia/Famagusta" => "CY", "Europe/Istanbul" => "TR", "Asia/Dubai" => "AE",
    "Asia/Bangkok" => "TH", "Asia/Jerusalem" => "IL", "Asia/Tel_Aviv" => "IL"
  }.freeze
  LANGUAGE_REGIONS = { "ru" => "RU", "be" => "BY", "kk" => "KZ", "uz" => "UZ", "uk" => "UA" }.freeze

  class << self
    def region?(region) = REGIONS.include?(region)

    # The region a new account starts with: the country of the browser's time
    # zone, else the region of the preferred language (ru-RU, then ru → RU).
    def detect(time_zone: nil, accept_language: nil)
      [ zone_country(time_zone), *language_regions(accept_language) ].compact.find { region?(_1) }
    end

    def for(region) = new(region)

    private

    # tzdata shares one zone between neighbours (Europe/Oslo is a link to
    # Europe/Berlin, Asia/Bangkok also serves Vietnam), so the capitals browsers
    # report are listed here and only zones of a single country are looked up.
    def zone_country(time_zone)
      return if time_zone.blank?

      ZONES[time_zone] || [ time_zone, TZInfo::Timezone.get(time_zone).canonical_identifier ].uniq.filter_map do |zone|
        countries = zone_countries[zone]
        countries.first if countries&.size == 1
      end.first
    rescue TZInfo::InvalidTimezoneIdentifier
      nil
    end

    def zone_countries
      @zone_countries ||= TZInfo::Country.all.each_with_object({}) do |country, map|
        country.zone_identifiers.each { (map[_1] ||= []) << country.code }
      end
    end

    def language_regions(header)
      tags = header.to_s.split(",").map { _1.split(";").first.to_s.strip }
      tags.filter_map { _1.split("-")[1]&.upcase } + tags.filter_map { LANGUAGE_REGIONS[_1.first(2).downcase] }
    end
  end

  attr_reader :region

  def initialize(region)
    @region = self.class.region?(region) ? region : nil
  end

  # Days of the week off (0 = Sunday), holidays on working days of the week and
  # working days on weekends, around today; the board falls back to weekends
  # outside the range.
  def as_board_json(today: Date.current)
    years = (today.year - 1)..(today.year + 1)
    days = years.map { |year| self.class.cache.fetch([ region, year ]) { year_days(year) } }
    {
      region:,
      weekend: weekend,
      holidays: days.flat_map(&:first),
      workdays: days.flat_map(&:last)
    }
  end

  def self.cache = @cache ||= Concurrent::Map.new

  private

  def weekend = WEEKENDS.fetch(region, [ 0, 6 ])

  def year_days(year)
    return [ [], [] ] if region.nil?
    return production_days(year) if PRODUCTION.include?(region)

    range = Date.new(year, 1, 1)..Date.new(year, 12, 31)
    holidays = Holidays.between(range.first, range.last, region.downcase.to_sym, :observed)
                       .map { _1[:date] }.uniq.reject { weekend.include?(_1.wday) }
    [ holidays.sort.map(&:iso8601), [] ]
  rescue Holidays::InvalidRegion, Holidays::UnknownRegionError
    [ [], [] ]
  end

  def production_days(year)
    data = self.class.production_data(region)
    prefix = year.to_s
    [ data["holidays"].select { _1.start_with?(prefix) }, data["workdays"].select { _1.start_with?(prefix) } ]
  end

  def self.production_data(region)
    @production_data ||= {}
    @production_data[region] ||= YAML.load_file(Rails.root.join("config/calendars/#{region.downcase}.yml"))
  end
end
