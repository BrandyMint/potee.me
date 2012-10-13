class EventsController < ApplicationController
  inherit_resources

  respond_to :js, :json, :html
end
