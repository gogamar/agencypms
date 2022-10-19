require "test_helper"

class FeaturesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get features_new_url
    assert_response :success
  end

  test "should get index" do
    get features_index_url
    assert_response :success
  end
end
