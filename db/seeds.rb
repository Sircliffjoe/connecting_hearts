# Seeds file for Connecting Hearts for Singles & Married Foundation

puts "Seeding Connecting Hearts Foundation database..."

# 1. Admin User
admin = User.find_or_create_by!(email: "admin@connectingheartsng.org") do |u|
  u.name = "Eloho Sodje (Admin)"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = "super_admin"
  u.image_url = "founder.png"
end
puts "✓ Admin user created: #{admin.email}"

# 2. Events (Connecting Hearts Experience History & Launch)
event1 = Event.find_or_create_by!(edition_number: "1.0") do |e|
  e.title = "Connecting Hearts Experience 1.0"
  e.theme = "This Thing Called Love"
  e.event_date = DateTime.parse("2025-07-05 10:00:00 +0100")
  e.location = "Warri, Delta State, Nigeria"
  e.description = "The inaugural edition that brought together over 100 singles and married individuals for honest conversations on vulnerability, expectations, and emotional healing."
  e.featured = false
  e.capacity = 150
  e.image_url = "/assets/pic113.jpeg"
end

event2 = Event.find_or_create_by!(edition_number: "2.0") do |e|
  e.title = "Connecting Hearts Experience 2.0"
  e.theme = "Loving You"
  e.event_date = DateTime.parse("2025-10-18 10:00:00 +0100")
  e.location = "Warri, Delta State, Nigeria"
  e.description = "Deep diving into self-worth, emotional intelligence, and building healthy boundaries before and during marriage."
  e.featured = false
  e.capacity = 180
  e.image_url = "/assets/pic114.jpeg"
end

event3 = Event.find_or_create_by!(edition_number: "3.0") do |e|
  e.title = "Connecting Hearts Experience 3.0"
  e.theme = "Love, Sex & Money"
  e.event_date = DateTime.parse("2026-03-21 10:00:00 +0100")
  e.location = "Warri, Delta State, Nigeria"
  e.description = "Tackling the three most sensitive pressure points in modern relationships and marriages: emotional intimacy, sexual compatibility, and financial stewardship."
  e.featured = false
  e.capacity = 220
  e.image_url = "/assets/pic115b.jpeg"
end

event4 = Event.find_or_create_by!(edition_number: "4.0") do |e|
  e.title = "Connecting Hearts Experience 4.0 & Foundation Grand Launch"
  e.theme = "The Conversation Continues. The Mission Begins."
  e.event_date = DateTime.parse("2026-08-01 10:00:00 +0100")
  e.location = "Grand Event Centre, Warri, Delta State, Nigeria"
  e.description = "The official institutional launch of the Connecting Hearts for Singles & Married Foundation, featuring keynotes, panel debates, live counseling sessions, and scholarship unveilings."
  e.featured = true
  e.capacity = 500
  e.registration_link = "#register"
  e.image_url = "/assets/pic116.jpeg"
end
puts "✓ 4 Events created."

# 3. Testimonials
Testimonial.find_or_create_by!(author_name: "Anita O.") do |t|
  t.relationship_status = "Married 6 years"
  t.quote = "Connecting Hearts Experience gave my spouse and me a safe, non-judgmental space to talk about things we had swept under the rug for years. It saved our marriage."
  t.edition_title = "Connecting Hearts Experience 2.0"
  t.featured = true
  t.approved = true
end

Testimonial.find_or_create_by!(author_name: "David K.") do |t|
  t.relationship_status = "Single"
  t.quote = "As a single man, I used to think relationship discussions were just for couples. 3.0 opened my eyes to emotional readiness and financial transparency before saying 'I do'."
  t.edition_title = "Connecting Hearts Experience 3.0"
  t.featured = true
  t.approved = true
end

Testimonial.find_or_create_by!(author_name: "Blessing & Emmanuel N.") do |t|
  t.relationship_status = "Engaged"
  t.quote = "The therapy and counseling session referred by Eloho Sodje helped us heal past emotional baggage before taking our vows. We are forever grateful."
  t.edition_title = "Connecting Hearts Experience 1.0"
  t.featured = true
  t.approved = true
end
puts "✓ Testimonials created."

# 4. Stories & Impact
Story.find_or_create_by!(title: "From a Single Gathering to an Enduring Refuge") do |s|
  s.category = "Founder Reflection"
  s.summary = "Eloho Sodje reflects on why July 5, 2025 was just the beginning of a larger institutional movement."
  s.body = "When we hosted the first Connecting Hearts Experience on July 5, 2025, our goal was simple: create one room where people could speak honestly about relationship pain without shame. What we discovered was a profound hunger. People were suffering in silence behind polished smiles. We knew an annual or quarterly event was not enough. People needed daily, weekly, ongoing support—professional counseling, crisis mediation, and education for innocent children affected by marital breakdown. That conviction gave birth to the Foundation."
  s.published = true
  s.featured = true
  s.image_url = "/assets/pic120.jpeg"
end

Story.find_or_create_by!(title: "Restoring Educational Hope for 12-Year-Old Samuel") do |s|
  s.category = "Beneficiary Story"
  s.summary = "How the Foundation's Educational Support Pillar stepped in when family dissolution threatened a young boy's schooling in Warri."
  s.body = "Following his parents' bitter separation, 12-year-old Samuel was forced out of school for two terms due to unpaid fees and abandonment. Through the Connecting Hearts Educational Support Pillar, Samuel was re-enrolled in school, provided with complete uniforms, textbooks, and a mentorship pairing. Today, Samuel is thriving at the top of his class."
  s.published = true
  s.featured = true
  s.image_url = "/assets/pic122.jpeg"
end
puts "✓ Impact Stories created."

# 5. Resources
Resource.find_or_create_by!(title: "Navigating Financial Conflict in Marriage: A Practical Guide") do |r|
  r.category = "Marriage"
  r.resource_type = "Article"
  r.summary = "Money disputes are among the leading causes of marital stress. Here are 5 practical ways to align your financial goals."
  r.content = "Financial transparency is emotional transparency. In this guide, we explore how couples in Nigeria can create combined budgeting frameworks, handle extended family expectations gracefully, and build shared emergency savings."
  r.published = true
  r.image_url = "/assets/pic115b.jpeg"
  r.gallery_images = ["/assets/pic116.jpeg", "/assets/pic117.jpeg", "/assets/pic114.jpeg", "/assets/pic113.jpeg"]
end

Resource.find_or_create_by!(title: "Emotional Healing After Separation or Divorce") do |r|
  r.category = "Emotional Wellbeing"
  r.resource_type = "PDF Guide"
  r.summary = "A compassionate, step-by-step workbook for processing grief, restoring self-worth, and protecting children during separation."
  r.content = "Separation does not mean your life is over. This workbook provides gentle exercises to rebuild your sense of self, release shame, and establish healthy co-parenting boundaries."
  r.published = true
  r.image_url = "/assets/pic120.jpeg"
  r.gallery_images = ["/assets/pic122.jpeg", "/assets/pic113.jpeg", "/assets/pic114.jpeg", "/assets/pic116.jpeg"]
end

Resource.find_or_create_by!(title: "Red Flags vs. Healing Markers in Dating") do |r|
  r.category = "Singles"
  r.resource_type = "Article"
  r.summary = "Distinguishing between temporary character flaws and fundamental incompatibility before committing."
  r.content = "Before saying 'I do', understand the difference between someone who is actively growing and someone who is emotionally unsafe. Learn how to evaluate values, conflict resolution styles, and emotional maturity."
  r.published = true
  r.image_url = "/assets/pic118.jpeg"
  r.gallery_images = ["/assets/pic117.jpeg", "/assets/pic115b.jpeg", "/assets/pic116.jpeg", "/assets/pic114.jpeg"]
end

Resource.find_or_create_by!(title: "Frequently Asked Questions About Confidential Counseling") do |r|
  r.category = "Communication"
  r.resource_type = "FAQ"
  r.summary = "Everything you need to know about requesting free or subsidized counseling through the Foundation."
  r.content = "All counseling requests submitted through Connecting Hearts Foundation are strictly confidential. Sessions are conducted by certified family counselors and licensed therapists in our Warri network."
  r.published = true
  r.image_url = "/assets/pic116.jpeg"
  r.gallery_images = ["/assets/pic120.jpeg", "/assets/pic122.jpeg", "/assets/pic113.jpeg", "/assets/pic115b.jpeg"]
end
puts "✓ Resources created."

# 6. Sample Support Requests (for Admin Demo)
SupportRequest.find_or_create_by!(email: "grace.m@example.com") do |sr|
  sr.full_name = "Grace M."
  sr.phone = "08031234567"
  sr.preferred_contact_method = "WhatsApp"
  sr.support_category = "Couples Counseling"
  sr.session_format = "In-Person (Warri)"
  sr.situation_description = "My partner and I have been experiencing severe communication breakdown over the past 8 months. We want to work with a compassionate counselor before making any decisions."
  sr.consent_given = true
  sr.status = "pending"
end

SupportRequest.find_or_create_by!(email: "victor.o@example.com") do |sr|
  sr.full_name = "Victor O."
  sr.phone = "08149876543"
  sr.preferred_contact_method = "Phone Call"
  sr.support_category = "Educational Support for Children"
  sr.session_format = "Online / Virtual"
  sr.situation_description = "I am a single father caring for two young children after a difficult separation. I am seeking educational subsidy support to keep them in primary school."
  sr.consent_given = true
  sr.status = "pending"
end
puts "✓ Sample Support Requests created."

puts "Database seeding completed successfully!"




