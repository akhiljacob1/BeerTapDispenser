require "test_helper"

class DispensersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dispensers_index_url
    assert_response :success
  end

  test "should get show" do
    get dispensers_show_url
    assert_response :success
  end

  test "should get create" do
    get dispensers_create_url
    assert_response :success
  end
end
