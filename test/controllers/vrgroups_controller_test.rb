require "test_helper"

class VrgroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @vrgroup = vrgroups(:one)
  end

  test "should get index" do
    get vrgroups_url
    assert_response :success
  end

  test "should get new" do
    get new_vrgroup_url
    assert_response :success
  end

  test "should create vrgroup" do
    assert_difference("Vrgroup.count") do
      post vrgroups_url, params: { vrgroup: { name: @vrgroup.name, office_id: @vrgroup.office_id } }
    end

    assert_redirected_to vrgroup_url(Vrgroup.last)
  end

  test "should show vrgroup" do
    get vrgroup_url(@vrgroup)
    assert_response :success
  end

  test "should get edit" do
    get edit_vrgroup_url(@vrgroup)
    assert_response :success
  end

  test "should update vrgroup" do
    patch vrgroup_url(@vrgroup), params: { vrgroup: { name: @vrgroup.name, office_id: @vrgroup.office_id } }
    assert_redirected_to vrgroup_url(@vrgroup)
  end

  test "should destroy vrgroup" do
    assert_difference("Vrgroup.count", -1) do
      delete vrgroup_url(@vrgroup)
    end

    assert_redirected_to vrgroups_url
  end
end
