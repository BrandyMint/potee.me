# encoding: utf-8

require 'requests/requests_helper'

feature "getting started", :js => true do

  background do
    visit("/")
    click_on "Get started"
  end

  context "on getting started" do
    specify "sample projects should be created" do
      within("#projects") do
        find(".project.project-color-0").visible?
        find(".project.project-color-1").visible?
        find(".project.project-color-2").visible?
      end
    end
  end

  scenario "add project" do
    # click "create project"
    find_link("new-project-link").visible?
    click_on("new-project-link")
    # a new project should be created
    within("#projects") do
      find(".project.project-color-3").visible?
      within(".project.project-color-3 .project-title") do
        find("form#new-project").visible?
        within("form#new-project") do
          find("input#title").value.should == "Your project name"
        end
      end
    end

    # change the project name and ok
    within("#projects .project.project-color-3 form#new-project") do
      fill_in "title", :with => "Learn Potee"
      click_on "submit"
    end
    # the project name should be saved
    within("#projects .project.project-color-3") do
      find(".project-title-el").text.should == "Learn Potee".upcase
    end

  end

  context "a new project added" do

    background do
      # create project
      click_on("new-project-link")
    end

    scenario "change project name" do
      pending "TBD"
    end

    scenario "add event to a new project" do
      # add event
      within("#projects .project.project-color-3") do
        find(".progress > .bar").click
      end
      # new event should be created
      within("#projects .project.project-color-3") do
        find(".event").visible?
        find(".event .event-title-el").text.should == "Some event"
      end

    end

    context "an event added" do

      background do
        within("#projects .project.project-color-3") do
          find(".progress > .bar").click
        end
      end

      scenario "change event name" do
        pending "Does not work against Selenium (Firefox)"

        # change the event name
        within("#projects .project.project-color-3") do
          # click on event title
          find(".event .event-bar").visible?
          find(".event .event-bar").click
          # title edit form should appear
          find(".event form#edit-event").visible?
          # change title
          within(".event form#edit-event") do
            fill_in "title", :with => "get started"
            click_on "submit"
          end
        end
        # the event name should change
        within("#projects .project.project-color-3") do
          find(".event .event-title-el").text.should == "get started"
        end

      end

    end

  end

end