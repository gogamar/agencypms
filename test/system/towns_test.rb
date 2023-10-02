require "application_system_test_case"

class TownsTest < ApplicationSystemTestCase
  setup do
    @town = towns(:one)
  end

  test "visiting the index" do
    visit towns_url
    assert_selector "h1", text: "Towns"
  end

  test "should create town" do
    visit towns_url
    click_on "New town"

    fill_in "Description", with: @town.description
    fill_in "Name", with: @town.name
    click_on "Create Town"

    assert_text "Town was successfully created"
    click_on "Back"
  end

  test "should update Town" do
    visit town_url(@town)
    click_on "Edit this town", match: :first

    fill_in "Description", with: @town.description
    fill_in "Name", with: @town.name
    click_on "Update Town"

    assert_text "Town was successfully updated"
    click_on "Back"
  end

  test "should destroy Town" do
    visit town_url(@town)
    click_on "Destroy this town", match: :first

    assert_text "Town was successfully destroyed"
  end
end
