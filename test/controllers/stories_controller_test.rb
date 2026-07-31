require "test_helper"

class StoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @story = stories(:one) rescue Story.create!(
      title: "Test Impact Story",
      summary: "A story of hope and transformation",
      body: "This is the full text of the test story for testing the show view layout and design.",
      category: "Beneficiary Story",
      published: true
    )
  end

  test "should get index" do
    get stories_url
    assert_response :success
  end

  test "should get show" do
    get story_url(@story)
    assert_response :success
    assert_select "h1", text: @story.title
  end
end
