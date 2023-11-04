require "application_system_test_case"

class RegionsTest < ApplicationSystemTestCase
  setup do
    @region = regions(:one)
  end

  test "visiting the index" do
    visit regions_url
    assert_selector "h1", text: "Regions"
  end

  test "should create region" do
    visit regions_url
    click_on "New region"

    fill_in "Description ca", with: @region.description_ca
    fill_in "Description en", with: @region.description_en
    fill_in "Description es", with: @region.description_es
    fill_in "Description fr", with: @region.description_fr
    fill_in "Name ca", with: @region.name_ca
    fill_in "Name en", with: @region.name_en
    fill_in "Name es", with: @region.name_es
    fill_in "Name fr", with: @region.name_fr
    click_on "Create Region"

    assert_text "Region was successfully created"
    click_on "Back"
  end

  test "should update Region" do
    visit region_url(@region)
    click_on "Edit this region", match: :first

    fill_in "Description ca", with: @region.description_ca
    fill_in "Description en", with: @region.description_en
    fill_in "Description es", with: @region.description_es
    fill_in "Description fr", with: @region.description_fr
    fill_in "Name ca", with: @region.name_ca
    fill_in "Name en", with: @region.name_en
    fill_in "Name es", with: @region.name_es
    fill_in "Name fr", with: @region.name_fr
    click_on "Update Region"

    assert_text "Region was successfully updated"
    click_on "Back"
  end

  test "should destroy Region" do
    visit region_url(@region)
    click_on "Destroy this region", match: :first

    assert_text "Region was successfully destroyed"
  end
end
