require "application_system_test_case"

class RatePlansTest < ApplicationSystemTestCase
  setup do
    @rate_plan = rate_plans(:one)
  end

  test "visiting the index" do
    visit rate_plans_url
    assert_selector "h1", text: "Rate plans"
  end

  test "should create rate plan" do
    visit rate_plans_url
    click_on "New rate plan"

    fill_in "Arrival", with: @rate_plan.arrival
    fill_in "End", with: @rate_plan.end
    fill_in "Min", with: @rate_plan.min
    fill_in "Start", with: @rate_plan.start
    click_on "Create Rate plan"

    assert_text "Rate plan was successfully created"
    click_on "Back"
  end

  test "should update Rate plan" do
    visit rate_plan_url(@rate_plan)
    click_on "Edit this rate plan", match: :first

    fill_in "Arrival", with: @rate_plan.arrival
    fill_in "End", with: @rate_plan.end
    fill_in "Min", with: @rate_plan.min
    fill_in "Start", with: @rate_plan.start
    click_on "Update Rate plan"

    assert_text "Rate plan was successfully updated"
    click_on "Back"
  end

  test "should destroy Rate plan" do
    visit rate_plan_url(@rate_plan)
    click_on "Destroy this rate plan", match: :first

    assert_text "Rate plan was successfully destroyed"
  end
end
