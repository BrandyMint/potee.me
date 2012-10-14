class ProjectsController < ApplicationController
  inherit_resources

  before_filter :authorize_user

  respond_to :js, :json, :html

protected

  def begin_of_association_chain
    @current_user
  end

end
