require "test_helper"

class Admin::TestimonialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) rescue User.create!(name: "Admin User", email: "admin@connectingheartsng.org", password: "password123", role: "admin")
    post admin_login_url, params: { email: @user.email, password: "password123" }
    @testimonial = Testimonial.create!(
      author_name: "Test Participant",
      relationship_status: "Single",
      edition_title: "Experience 1.0",
      quote: "Amazing relationship insights!",
      approved: true
    )
  end

  test "should get index" do
    get admin_testimonials_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_testimonial_url
    assert_response :success
  end

  test "should create testimonial" do
    assert_difference("Testimonial.count") do
      post admin_testimonials_url, params: {
        testimonial: {
          author_name: "Blessed O.",
          relationship_status: "Engaged",
          edition_title: "Experience 4.0",
          quote: "A truly life-changing gathering in Warri.",
          approved: true,
          featured: true
        }
      }
    end

    assert_redirected_to admin_testimonials_url
  end

  test "should get edit" do
    get edit_admin_testimonial_url(@testimonial)
    assert_response :success
  end

  test "should update testimonial" do
    patch admin_testimonial_url(@testimonial), params: {
      testimonial: {
        author_name: "Updated Name",
        quote: "Updated quote."
      }
    }
    assert_redirected_to admin_testimonials_url
    @testimonial.reload
    assert_equal "Updated Name", @testimonial.author_name
  end

  test "should destroy testimonial" do
    assert_difference("Testimonial.count", -1) do
      delete admin_testimonial_url(@testimonial)
    end

    assert_redirected_to admin_testimonials_url
  end
end
