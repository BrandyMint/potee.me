describe "Potee.Views.DashboardView", ->
  beforeEach ->
    setFixtures "<section id='viewport'><div id='dashboard'></div></section>"
    appendSetFixtures("<div id='project_new'><a id='new-project-link'>New project</a></div>")

    projects = new Potee.Collections.ProjectsCollection()
    window.projects = projects
    @model = new Potee.Models.Dashboard({}, {}, projects)
    window.dashboard = @model
    @view = new Potee.Views.DashboardView({model: @model})

  it "should have #dashboard as element", ->
    expect(@view.el).toBeDefined()
    expect($(@view.el)).toBe "#dashboard"

  describe "rendering", ->
    it "should have timeline", ->
      expect(@view.$el).toContain "#timeline"

    it "should have projects", ->
      expect(@view.$el).toContain "#projects"
      expect(@view.projects_view).toBeDefined()

  describe "clean dashboard", ->
    it "should have no project", ->
      expect($("#projects")).not.toContain ".project"

    describe "in week scale", ->
      beforeEach ->
        @$today_column = $("tbody td.day.current")

      it "should have three days before today", ->
        expect(@$today_column.prevAll("td").length).toEqual 3

      it "should have one month and 3 days after today", ->
        days = moment().add("months", 1).endOf("month").diff(moment().startOf("day"), "days") + 3
        expect(@$today_column.nextAll("td").length).toEqual days

      it "should have appropriate width", ->
        expect(@view.$el.width()).toEqual (3 + 1 + (moment().add("months", 1).endOf("month").diff(moment().startOf("day"), "days") + 3)) * @model.get('pixels_per_day')

  describe "actions", ->
    describe "new project via 'New project' button", ->
      beforeEach ->
        $("#new-project-link").click()

      it "should activate 'New project' button", ->
        expect($("#project_new")).toHaveClass "active"

      it "should create new project", ->
        expect($("#projects")).toContain ".project"
        expect($("#projects")).toContain ".project .project-title form#new-project"

    describe "user scroll the timeline", ->
      beforeEach ->
        @offset = @model.get('pixels_per_day') * 3 # на три дня влево
        @view.viewport.scrollLeft @offset
        @view.viewport.trigger "scroll"

      it "should change current date", ->
        expect(@model.getCurrentDate()).toEqual @model.datetimeAt(@offset + (@view.viewportWidth() / 2)).toDate()

  describe "go to date", ->
    describe "in week scale", ->
      it "should center the date column via 1 second animation", ->
        flag = false

        runs =>
          # чтобы наверняка смогли отцентировать.
          days_after_today = Math.ceil($(document).width() / @model.get('pixels_per_day'))
          $today_column = $("tbody td.day.current")
          @$dayColumn = $($today_column.nextAll()[days_after_today-1])
          @view.gotoDate moment().add("days", days_after_today).startOf("day").add("hours", 12)
          setTimeout (-> flag = true ), 2000

        waitsFor (-> flag), "gotToDate not finished", 3000

        runs =>
          actual = @$dayColumn.offset().left + @$dayColumn.width() / 2
          expected = $(document).width() / 2
          expect(Math.abs(expected - actual)).toBeLessThan(5)