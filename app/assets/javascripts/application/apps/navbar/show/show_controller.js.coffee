@Potee.module "NavbarApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.Controller extends Marionette.Controller
    
    initialize: ->
      @showLayoutView()
      @showProjectControl()
      @showTimePeriods()
      @showMoveToToday()
      @showUserProfile()

    showLayoutView: ->
      @layout = @getLayoutView()
      App.navbarRegion.attachView @layout

    showProjectControl: ->
      projectControlView = @getProjectControlView()
      @layout.projectControlRegion.attachView projectControlView

    showTimePeriods: ->
      timePeriodsView = @getTimePeriodsView()
      @layout.timePeriodsRegion.attachView timePeriodsView

    showMoveToToday: ->
      moveToTodayView = @getMoveToTodayView()
      @layout.moveToTodayRegion.attachView moveToTodayView
    
    showUserProfile: ->
      userProfileView = @getUserProfileView()
      @layout.userProfileRegion.attachView userProfileView

    getLayoutView: ->
      new Show.Layout()

    getProjectControlView: ->
      new Show.ProjectControl()

    getTimePeriodsView: ->
      new Show.TimePeriods()

    getMoveToTodayView: ->
      new Show.MoveToToday()

    getUserProfileView: ->
      new Show.UserProfile()

