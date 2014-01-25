@Potee.module "NavbarApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.Layout extends Marionette.Layout
    el: '#navbar-region'

    regions: 
      projectControlRegion : '#project_control'
      timePeriodsRegion    : '#scale-nav'
      moveToTodayRegion    : '#today-nav'
      userProfileRegion    : '#user-profile'

  class Show.ProjectControl extends Marionette.ItemView
    el: '#project_control'

  class Show.TimePeriods extends Marionette.ItemView
    el: '#scale-nav'

  class Show.MoveToToday extends Marionette.ItemView
    el: '#today-nav'

  class Show.UserProfile extends Marionette.ItemView
    el: '#user-profile'