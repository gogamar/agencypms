require "application_system_test_case"

class ChargesTest < ApplicationSystemTestCase
  setup do
    @charge = charges(:one)
  end

  test "visiting the index" do
    visit charges_url
    assert_selector "h1", text: "Charges"
  end

  test "should create charge" do
    visit charges_url
    click_on "New charge"

    fill_in "Booking", with: @charge.booking_id
    fill_in "Description", with: @charge.description
    fill_in "Price", with: @charge.price
    fill_in "Quantity", with: @charge.quantity
    click_on "Create Charge"

    assert_text "Charge was successfully created"
    click_on "Back"
  end

  test "should update Charge" do
    visit charge_url(@charge)
    click_on "Edit this charge", match: :first

    fill_in "Booking", with: @charge.booking_id
    fill_in "Description", with: @charge.description
    fill_in "Price", with: @charge.price
    fill_in "Quantity", with: @charge.quantity
    click_on "Update Charge"

    assert_text "Charge was successfully updated"
    click_on "Back"
  end

  test "should destroy Charge" do
    visit charge_url(@charge)
    click_on "Destroy this charge", match: :first

    assert_text "Charge was successfully destroyed"
  end
end
