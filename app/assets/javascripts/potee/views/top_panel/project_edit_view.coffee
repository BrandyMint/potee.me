Potee.Views.TopPanel = {}

class Potee.Views.TopPanel.ProjectDetailView extends Marionette.ItemView
  template: "templates/top_panel/project_detail_view"

  ui:
    title: "input#title"
    submitButton: "#submit-btn"

  bindings: 
    "#title":
      observe: 'title'
      updateModel: false

  events:
    "click @ui.submitButton": 'submit'

  submit: (e) ->
    @model.set 'title', _.escape @ui.title.val()
    @model.save(null,
      success : (project) =>
        @model = project
        #window.dashboard.view.cancelCurrentForm()
        @model.view.setTitleView 'show'
    )  

  onRender: ->
    @stickit()