require 'spec_helper'

describe WelcomeController do
  it "should get index" do
    get :index
    response.should be_success
  end
end