class DummyProjectsObserver < ActiveRecord::Observer
  observe :user

  def after_create user
    projects = Project.create([
      {owner: user, title: 'Learn Scala', started_at: Date.today, finish_at: 10.days.since },
      {owner: user, title: 'Make my wife happy', started_at: Date.today-2.days, finish_at: 11.days.since },
      {owner: user, title: 'Start my own business', started_at: Date.today-3.days, finish_at: 12.days.since },
    ])

    p = projects.first
    p.project_connections.create color_index: 1, user: user, position: 1
    p.events.create([
      {title: 'By a book', date: Date.tomorrow + 1.day, time: Time.current},
      {title: 'Read some interesting posts', date: 4.days.since, time: Time.current},
      {title: 'Went to the conference', date: 7.days.since, time: Time.current}
    ])
    p = projects[1]
    p.project_connections.create color_index: 2, user: user, position: 2
    p.events.create([
      {title: 'Buy a present', date: Date.today, time: Time.current},
      {title: 'Go shopping together', date: 10.days.since, time: Time.current}
    ])
    p = projects.last
    p.project_connections.create color_index: 3, user: user, position: 3
    p.events.create([
      {title: 'Think about the idea', date: Date.tomorrow+4.day, time: Time.current}
    ])
  end
end
