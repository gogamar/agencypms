require "test_helper"

class ImageUrlsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @image_url = image_urls(:one)
  end

  test "should get index" do
    get image_urls_url
    assert_response :success
  end

  test "should get new" do
    get new_image_url_url
    assert_response :success
  end

  test "should create image_url" do
    assert_difference("ImageUrl.count") do
      post image_urls_url, params: { image_url: { order: @image_url.order, url: @image_url.url } }
    end

    assert_redirected_to image_url_url(ImageUrl.last)
  end

  test "should show image_url" do
    get image_url_url(@image_url)
    assert_response :success
  end

  test "should get edit" do
    get edit_image_url_url(@image_url)
    assert_response :success
  end

  test "should update image_url" do
    patch image_url_url(@image_url), params: { image_url: { order: @image_url.order, url: @image_url.url } }
    assert_redirected_to image_url_url(@image_url)
  end

  test "should destroy image_url" do
    assert_difference("ImageUrl.count", -1) do
      delete image_url_url(@image_url)
    end

    assert_redirected_to image_urls_url
  end
end
