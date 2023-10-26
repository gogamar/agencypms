require "application_system_test_case"

class VrgroupsTest < ApplicationSystemTestCase
  setup do
    @vrgroup = vrgroups(:one)
  end

  test "visiting the index" do
    visit vrgroups_url
    assert_selector "h1", text: "Vrgroups"
  end

  test "should create vrgroup" do
    visit vrgroups_url
    click_on "New vrgroup"

    fill_in "Name", with: @vrgroup.name
    fill_in "Office", with: @vrgroup.office_id
    click_on "Create Vrgroup"

    assert_text "Vrgroup was successfully created"
    click_on "Back"
  end

  test "should update Vrgroup" do
    visit vrgroup_url(@vrgroup)
    click_on "Edit this vrgroup", match: :first

    fill_in "Name", with: @vrgroup.name
    fill_in "Office", with: @vrgroup.office_id
    click_on "Update Vrgroup"

    assert_text "Vrgroup was successfully updated"
    click_on "Back"
  end

  test "should destroy Vrgroup" do
    visit vrgroup_url(@vrgroup)
    click_on "Destroy this vrgroup", match: :first

    assert_text "Vrgroup was successfully destroyed"
  end
end
