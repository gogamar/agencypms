require "application_system_test_case"

class RatePeriodsTest < ApplicationSystemTestCase
  setup do
    @rate_period = rate_periods(:one)
  end

  test "visiting the index" do
    visit rate_periods_url
    assert_selector "h1", text: "Rate periods"
  end

  test "should create rate period" do
    visit rate_periods_url
    click_on "New rate period"

    fill_in "Arrival day", with: @rate_period.arrival_day
    fill_in "Firstnight", with: @rate_period.firstnight
    fill_in "Lastnight", with: @rate_period.lastnight
    fill_in "Min stay", with: @rate_period.min_stay
    fill_in "Name", with: @rate_period.name
    click_on "Create Rate period"

    assert_text "Rate period was successfully created"
    click_on "Back"
  end

  test "should update Rate period" do
    visit rate_period_url(@rate_period)
    click_on "Edit this rate period", match: :first

    fill_in "Arrival day", with: @rate_period.arrival_day
    fill_in "Firstnight", with: @rate_period.firstnight
    fill_in "Lastnight", with: @rate_period.lastnight
    fill_in "Min stay", with: @rate_period.min_stay
    fill_in "Name", with: @rate_period.name
    click_on "Update Rate period"

    assert_text "Rate period was successfully updated"
    click_on "Back"
  end

  test "should destroy Rate period" do
    visit rate_period_url(@rate_period)
    click_on "Destroy this rate period", match: :first

    assert_text "Rate period was successfully destroyed"
  end
end
