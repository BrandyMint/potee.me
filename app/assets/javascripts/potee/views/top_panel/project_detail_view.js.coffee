Potee.Views.TopPanel = {}

class Potee.Views.TopPanel.ProjectDetailView extends Marionette.ItemView
  template: "templates/top_panel/project_detail_view"
  id: "toppanel"

  ui:
    form         : "form"
    title        : "input#title"
    submitButton : "#submit-btn"
    cancelButton : "#cancel-btn"
    deleteButton : "#delete-btn"
    closeButton  : "#close-btn"
    shareLink    : '#share-link'

  bindings:
    "#title":
      observe: "title"
      updateModel: false
      onGet: (val) ->
        # Корректно выводим спецсимволы
        _.unescape val


  modelEvents:
    "destroy" : "closePanel"

  events:
    "focus @ui.title"        : "showControlButtons"
    "keyup @ui.title"        : "checkChanges"
    "blur @ui.title"         : "hideControlButtons"
    "click @ui.submitButton" : "saveChanges"
    "click @ui.cancelButton" : "cancelChanges"
    "click @ui.deleteButton" : "deleteProject"
    "click @ui.closeButton"  : "closePanel"
    "submit @ui.form"        : "saveChanges"

  checkChanges: (e) ->
    $el = $(e.target)

    if @_isEscapeButton e, $el
      @cancelChanges e
      @setViewMode()
      return

    if $el.val() is @model.get "title"
      $("#submit-btn").attr 'disabled', 'disabled'
      $("#cancel-btn").addClass "hidden"
    else
      $("#submit-btn").removeAttr 'disabled'
      $("#cancel-btn").removeClass "hidden"

  saveChanges: (e) ->
    e.preventDefault()
    e.stopPropagation()

    $el = $(e.target)
    return if $el.attr "disabled"
    @setViewMode()
    
    # Все знаки переводим в безопасные спецсимволы
    @model.set "title", _.escape @ui.title.val()
    @model.save(null,
      success : (project) =>
        @model = project
        #window.dashboard.view.cancelCurrentForm()
        @model.view.setTitleView "show"
    )

  deleteProject: (e) ->
    e.preventDefault()

    if confirm("Sure to delete?")
      @model.destroy()

  cancelChanges: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @ui.title.val @model.get "title"

  showControlButtons: (e) ->
    $el = $(e.target)

    $("#control-buttons").removeClass "hidden"

    unless $el.val() is @model.get "title"
      $("#cancel-btn").removeClass "hidden"

  hideControlButtons: ->
    setTimeout ->
      $("#control-buttons").addClass "hidden"
    , 100

  setViewMode: ->
    @ui.form.find("input").blur()

  closePanel: ->
    PoteeApp.seb.fire "project:current", undefined

  _isEscapeButton: (evt, input) ->
    code = evt.charCode || evt.keyCode
    if code == 27 then true else false

  onRender: ->
    @stickit()

