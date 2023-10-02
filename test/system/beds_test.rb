require "application_system_test_case"

class BedsTest < ApplicationSystemTestCase
  setup do
    @bed = beds(:one)
  end

  test "visiting the index" do
    visit beds_url
    assert_selector "h1", text: "Beds"
  end

  test "should create bed" do
    visit beds_url
    click_on "New bed"

    fill_in "Bed type", with: @bed.bed_type
    fill_in "Bedroom references", with: @bed.bedroom_references
    click_on "Create Bed"

    assert_text "Bed was successfully created"
    click_on "Back"
  end

  test "should update Bed" do
    visit bed_url(@bed)
    click_on "Edit this bed", match: :first

    fill_in "Bed type", with: @bed.bed_type
    fill_in "Bedroom references", with: @bed.bedroom_references
    click_on "Update Bed"

    assert_text "Bed was successfully updated"
    click_on "Back"
  end

  test "should destroy Bed" do
    visit bed_url(@bed)
    click_on "Destroy this bed", match: :first

    assert_text "Bed was successfully destroyed"
  end
end
