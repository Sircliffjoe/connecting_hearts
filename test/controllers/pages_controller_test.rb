require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get homepage" do
    get root_url
    assert_response :success
  end

  test "should get about page" do
    get about_url
    assert_response :success
  end

  test "should get our work page" do
    get our_work_url
    assert_response :success
  end

  test "should get counseling page" do
    get counseling_url
    assert_response :success
  end

  test "should get educational support page" do
    get educational_support_url
    assert_response :success
  end

  test "should get get involved page" do
    get get_involved_url
    assert_response :success
  end

  test "should get contact page" do
    get contact_url
    assert_response :success
  end

  test "should get experiences index" do
    get experiences_url
    assert_response :success
  end

  test "should get support request form" do
    get new_support_request_url
    assert_response :success
  end

  test "should get volunteer application form" do
    get new_volunteer_application_url
    assert_response :success
  end

  test "should get partnership inquiry form" do
    get new_partnership_inquiry_url
    assert_response :success
  end

  test "should get donation form" do
    get new_donation_url
    assert_response :success
  end

  test "should get stories index" do
    get stories_url
    assert_response :success
  end

  test "should get resources index" do
    get resources_url
    assert_response :success
  end
end
