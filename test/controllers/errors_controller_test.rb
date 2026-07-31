require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should render 404 page" do
    get "/404"
    assert_select "h1", text: /404/
  end

  test "should render 422 page" do
    get "/422"
    assert_select "h1", text: /422/
  end

  test "should render 500 page" do
    get "/500"
    assert_select "h1", text: /500/
  end
end
