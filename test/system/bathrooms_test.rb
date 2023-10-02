require "application_system_test_case"

class BathroomsTest < ApplicationSystemTestCase
  setup do
    @bathroom = bathrooms(:one)
  end

  test "visiting the index" do
    visit bathrooms_url
    assert_selector "h1", text: "Bathrooms"
  end

  test "should create bathroom" do
    visit bathrooms_url
    click_on "New bathroom"

    fill_in "Bathroom type", with: @bathroom.bathroom_type
    fill_in "Vrental", with: @bathroom.vrental_id
    click_on "Create Bathroom"

    assert_text "Bathroom was successfully created"
    click_on "Back"
  end

  test "should update Bathroom" do
    visit bathroom_url(@bathroom)
    click_on "Edit this bathroom", match: :first

    fill_in "Bathroom type", with: @bathroom.bathroom_type
    fill_in "Vrental", with: @bathroom.vrental_id
    click_on "Update Bathroom"

    assert_text "Bathroom was successfully updated"
    click_on "Back"
  end

  test "should destroy Bathroom" do
    visit bathroom_url(@bathroom)
    click_on "Destroy this bathroom", match: :first

    assert_text "Bathroom was successfully destroyed"
  end
end
