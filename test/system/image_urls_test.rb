require "application_system_test_case"

class ImageUrlsTest < ApplicationSystemTestCase
  setup do
    @image_url = image_urls(:one)
  end

  test "visiting the index" do
    visit image_urls_url
    assert_selector "h1", text: "Image urls"
  end

  test "should create image url" do
    visit image_urls_url
    click_on "New image url"

    fill_in "Order", with: @image_url.order
    fill_in "Url", with: @image_url.url
    click_on "Create Image url"

    assert_text "Image url was successfully created"
    click_on "Back"
  end

  test "should update Image url" do
    visit image_url_url(@image_url)
    click_on "Edit this image url", match: :first

    fill_in "Order", with: @image_url.order
    fill_in "Url", with: @image_url.url
    click_on "Update Image url"

    assert_text "Image url was successfully updated"
    click_on "Back"
  end

  test "should destroy Image url" do
    visit image_url_url(@image_url)
    click_on "Destroy this image url", match: :first

    assert_text "Image url was successfully destroyed"
  end
end
