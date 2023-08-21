require "application_system_test_case"

class TouristsTest < ApplicationSystemTestCase
  setup do
    @tourist = tourists(:one)
  end

  test "visiting the index" do
    visit tourists_url
    assert_selector "h1", text: "Tourists"
  end

  test "should create tourist" do
    visit tourists_url
    click_on "New tourist"

    fill_in "Address", with: @tourist.address
    fill_in "Country", with: @tourist.country
    fill_in "Country code", with: @tourist.country_code
    fill_in "Document", with: @tourist.document
    fill_in "Email", with: @tourist.email
    fill_in "Firstname", with: @tourist.firstname
    fill_in "Lastname", with: @tourist.lastname
    fill_in "Phone", with: @tourist.phone
    click_on "Create Tourist"

    assert_text "Tourist was successfully created"
    click_on "Back"
  end

  test "should update Tourist" do
    visit tourist_url(@tourist)
    click_on "Edit this tourist", match: :first

    fill_in "Address", with: @tourist.address
    fill_in "Country", with: @tourist.country
    fill_in "Country code", with: @tourist.country_code
    fill_in "Document", with: @tourist.document
    fill_in "Email", with: @tourist.email
    fill_in "Firstname", with: @tourist.firstname
    fill_in "Lastname", with: @tourist.lastname
    fill_in "Phone", with: @tourist.phone
    click_on "Update Tourist"

    assert_text "Tourist was successfully updated"
    click_on "Back"
  end

  test "should destroy Tourist" do
    visit tourist_url(@tourist)
    click_on "Destroy this tourist", match: :first

    assert_text "Tourist was successfully destroyed"
  end
end
