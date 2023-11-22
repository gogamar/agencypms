require "test_helper"

class AvailabilityRulesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get availability_rules_new_url
    assert_response :success
  end

  test "should get index" do
    get availability_rules_index_url
    assert_response :success
  end

  test "should get create" do
    get availability_rules_create_url
    assert_response :success
  end

  test "should get update" do
    get availability_rules_update_url
    assert_response :success
  end

  test "should get destroy" do
    get availability_rules_destroy_url
    assert_response :success
  end
end
