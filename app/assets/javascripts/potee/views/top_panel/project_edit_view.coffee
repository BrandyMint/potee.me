Potee.Views.TopPanel = {}

class Potee.Views.TopPanel.ProjectDetailView extends Marionette.ItemView
  template: "templates/top_panel/project_detail_view"

  ui:
    title: "input#title"
    submitButton: "#submit-btn"
    deleteButton: "#delete-btn"

  bindings: 
    "#title":
      observe: 'title'
      updateModel: false

  triggers:
    "click @ui.submitButton": 'project:submit'
    "click @ui.deleteButton": 'project:delete'

  onRender: ->
    @stickit()