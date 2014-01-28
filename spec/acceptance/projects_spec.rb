# encoding: utf-8

require 'acceptance/acceptance_helper'

feature "projects", :js => true do

  before do
    visit("/projects")
  end

  scenario "allready had 3 projects" do
    within("#projects") do
      find(".project.project-color-0").visible?
      find(".project.project-color-1").visible?
      find(".project.project-color-2").visible?
    end
  end


  scenario "add project" do
    pending
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

  scenario "add event to new project" do
    within("#projects .project.project-color-2") do
      find(".progress > .bar").click
    end

    within("#projects .project.project-color-2") do
      all(".event").last.visible?
      all(".event .event-title-el").last.text.should == "Some event"
    end
  end

  scenario "change event name" do

    within("#projects .project.project-color-2") do
      first(".event .event-bar").click
      pending
      within(".event form#edit-event") do
        fill_in "title", :with => "get started"
        click_on "submit"
      end

    end

    within("#projects .project.project-color-2") do
      all(".event").first.visible?
      first(".event .event-title-el").text.should == 'get started'
    end
  end
end
