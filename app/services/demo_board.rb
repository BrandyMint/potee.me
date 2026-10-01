# Fills a new user's board with sample projects so the first visit is not
# empty. Texts come from the `demo_board` locale key, dates are relative to today.
class DemoBoard
  SCHEDULE = [
    { start: 0, finish: 10, events: [ 2, 4, 7 ] },
    { start: -2, finish: 11, events: [ 0, 10 ] },
    { start: -3, finish: 12, events: [ 5 ] }
  ].freeze

  def self.fill(user, today: Date.current, locale: I18n.locale)
    new(user, today, locale).fill
  end

  def self.titles(locale = I18n.locale)
    I18n.t("demo_board.projects", locale:).map { _1[:title] }
  end

  def initialize(user, today, locale)
    @user = user
    @today = today
    @texts = I18n.t("demo_board.projects", locale:)
  end

  def fill
    SCHEDULE.zip(@texts).each_with_index do |(schedule, texts), index|
      project = @user.owned_projects.create!(
        title: texts[:title],
        started_on: @today + schedule[:start],
        finished_on: @today + schedule[:finish],
        demo: true
      )
      project.project_connections.create!(user: @user, position: index, color_index: index + 1)
      schedule[:events].zip(texts[:events]).each do |day, title|
        project.events.create!(title:, at: (@today + day).in_time_zone.change(hour: 12))
      end
    end
  end
end
