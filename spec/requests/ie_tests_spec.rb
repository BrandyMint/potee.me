# encoding: utf-8

require 'requests/all_browsers_helper' if RSpec.configuration.inclusion_filter[:ie_test] == true

describe "welcome page", :ie_test => true do

  before do
    visit("/")
  end

  it "should allow everybody to get started by click on 'Get started' link" do
    find_link("Get started").visible?
    click_on("Get started")
    current_path.should == "/projects"
  end

  it "should allow everybody to get started by click on logo" do
    find(".welcome-logo a").visible?
    find(".welcome-logo a").click
    current_path.should == "/projects"
  end

  it "should allow to access about info" do
    find_link("About").visible?
    click_on "About"
    current_path.should == "/pages/about"
  end

  it "should allow to access team info" do
    find_link("Team").visible?
    click_on "Team"
    current_path.should == "/pages/team"
  end

  it "should allow to access 'How it works' info" do
    find_link("How it works").visible?
    click_on("How it works")
    current_path.should == "/pages/how_it_works"
  end

end
