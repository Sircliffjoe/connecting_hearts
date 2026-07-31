require "test_helper"

class ExperiencesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get experiences_url
    assert_response :success
  end

  test "should show event details" do
    get experience_url("evt-40")
    assert_response :success
    assert_select "h1", text: /Connecting Hearts Experience 4.0/
  end

  test "admin should create event and sync via Eventro API" do
    user = users(:one) rescue User.create!(name: "Admin User", email: "admin@connectingheartsng.org", password: "password123", role: "admin")
    post admin_login_url, params: { email: user.email, password: "password123" }

    assert_difference("Event.count") do
      post admin_events_url, params: {
        event: {
          title: "New Eventro API Conference 5.0",
          theme: "Building Legacy Families",
          edition_number: "5.0",
          event_date: 2.weeks.from_now,
          location: "Warri, Delta State",
          capacity: 300,
          description: "A brand new event created via Eventro API."
        }
      }
    end

    assert_redirected_to admin_events_url
  end

  test "should submit participant reflection testimonial" do
    assert_difference("Testimonial.count") do
      post create_testimonial_experiences_url, params: {
        testimonial: {
          author_name: "Tari E.",
          relationship_status: "Married 3 Years",
          edition_title: "Experience 3.0",
          quote: "Connecting Hearts restored open communication in our marriage!"
        }
      }
    end

    assert_redirected_to experiences_path(anchor: "testimonials")
  end
end
