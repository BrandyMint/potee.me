describe "Potee.Models.Dashboard", ->
  beforeEach ->
    @projects = new Potee.Collections.ProjectsCollection
    @dashboard = new Potee.Models.Dashboard({}, {}, @projects)

  it "should have week scale by default", ->
    expect(@dashboard.get("scale")).toBe('week')

  describe "#datetimeAt", ->
    it "should return date from pixels", ->
      expect(@dashboard.datetimeAt(@dashboard.pixels_per_day*2)).toEqual moment(@dashboard.min_with_span()).add("days", 2)
      expect(@dashboard.datetimeAt(@dashboard.pixels_per_day*2.5)).toEqual moment(@dashboard.min_with_span()).add("days", 2).add("hours", 12)

  describe "#min_with_span", ->
    describe "of clean dashboard", ->
      beforeEach ->
        @dashboard.findStartEndDate()
      it "should equal 3 days before today", ->
        expect(@dashboard.min_with_span()).toEqual moment().subtract("days", 3).startOf("day").toDate()

  describe "#max_with_span", ->
    describe "of clean dashboard", ->
      beforeEach ->
        @dashboard.findStartEndDate()
      it "should equal 1 month and 3 days after today", ->
        expect(@dashboard.max_with_span()).toEqual moment().add("months", 1).endOf("month").add("days", 3).toDate()


