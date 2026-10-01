# Fills a new user's board with sample projects so the first visit is not empty.
class DemoBoard
  PROJECTS = [
    { title: "Learn Scala", start: 0, finish: 10,
      events: [ [ "Buy a book", 2 ], [ "Read some interesting posts", 4 ], [ "Go to the conference", 7 ] ] },
    { title: "Make my wife happy", start: -2, finish: 11,
      events: [ [ "Buy a present", 0 ], [ "Go shopping together", 10 ] ] },
    { title: "Start my own business", start: -3, finish: 12,
      events: [ [ "Think about the idea", 5 ] ] }
  ].freeze

  def self.fill(user, today: Date.current)
    new(user, today).fill
  end

  def initialize(user, today)
    @user = user
    @today = today
  end

  def fill
    PROJECTS.each_with_index do |spec, index|
      project = @user.owned_projects.create!(
        title: spec[:title],
        started_on: @today + spec[:start],
        finished_on: @today + spec[:finish]
      )
      project.project_connections.create!(user: @user, position: index, color_index: index + 1)
      spec[:events].each do |title, day|
        project.events.create!(title:, at: (@today + day).in_time_zone.change(hour: 12))
      end
    end
  end
end
