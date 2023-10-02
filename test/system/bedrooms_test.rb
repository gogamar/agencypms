require "application_system_test_case"

class BedroomsTest < ApplicationSystemTestCase
  setup do
    @bedroom = bedrooms(:one)
  end

  test "visiting the index" do
    visit bedrooms_url
    assert_selector "h1", text: "Bedrooms"
  end

  test "should create bedroom" do
    visit bedrooms_url
    click_on "New bedroom"

    fill_in "Bedroom type", with: @bedroom.bedroom_type
    fill_in "Vrental", with: @bedroom.vrental_id
    click_on "Create Bedroom"

    assert_text "Bedroom was successfully created"
    click_on "Back"
  end

  test "should update Bedroom" do
    visit bedroom_url(@bedroom)
    click_on "Edit this bedroom", match: :first

    fill_in "Bedroom type", with: @bedroom.bedroom_type
    fill_in "Vrental", with: @bedroom.vrental_id
    click_on "Update Bedroom"

    assert_text "Bedroom was successfully updated"
    click_on "Back"
  end

  test "should destroy Bedroom" do
    visit bedroom_url(@bedroom)
    click_on "Destroy this bedroom", match: :first

    assert_text "Bedroom was successfully destroyed"
  end
end
