Potee.Views.TopPanel = {}

class Potee.Views.TopPanel.ProjectDetailView extends Marionette.ItemView
  template: "templates/top_panel/project_detail_view"

  ui:
    form: "form"
    title: "input#title"
    submitButton: "#submit-btn"

  bindings:
    "#title":
      observe: "title"
      updateModel: false
      onGet: (val) ->
        # Корректно выводим спецсимволы
        _.unescape val

  events:
    "click @ui.submitButton": "saveChanges"
    "submit @ui.form": "saveChanges"

  saveChanges: (e) ->
    e.preventDefault()
    
    # Все знаки переводим в безопасные спецсимволы
    @model.set "title", _.escape @ui.title.val()
    @model.save(null,
      success : (project) =>
        @model = project
        #window.dashboard.view.cancelCurrentForm()
        @model.view.setTitleView "show"
        PoteeApp.seb.fire "project:current", undefined
    )

  onRender: ->
    @stickit()