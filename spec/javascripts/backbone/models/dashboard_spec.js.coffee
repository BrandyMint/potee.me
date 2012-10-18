describe "Potee.Models.Dashboard", ->

  it "should have week scale by default", ->
    projects = new Potee.Collections.ProjectsCollection
    dashboard = new Potee.Models.Dashboard(projects)
    expect(dashboard.get("scale")).toBe('week')

