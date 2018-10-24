require 'test_helper'

class FeaturesFlowTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver
    @alice = FactoryBot.create(:alice)
    @bob = FactoryBot.create(:bob)
  end
  
  test "Publish a post" do
    login_as(@alice, scope: :user, run_callbacks: false)
    
    visit "/"
    
    within("#new_post") do
      fill_in "post[content]", with: "Post #1"
    end
    click_on "Post"
    
    assert Post.last.user, @alice
    assert_text "Post #1"
  end
  
  test "Repost a post" do
    login_as(@alice, scope: :user, run_callbacks: false)
    
    visit "/"
    
    within("#new_post") do
      fill_in "post[content]", with: "Post #1"
    end
    click_on "Post"
    
    assert_text "Post #1"
    
    reset!
    
    @bob.follow(@alice.username)
    login_as(@bob, scope: :user, run_callbacks: false)
    
    visit "/"
    
    assert_text "Bob"
    
    post = Post.last

    within "#post-row-#{post.id}" do
      click_on "Repost"
    end
    
    assert_text "Add message to repost"
    assert_equal post.id.to_s, find('#repostModal [name="original_post_id"]', visible: false).value

    within "#repostModal" do
      click_on "Repost"
    end
    
    post = Post.last
    
    assert_equal @bob, Post.last.user, "User (#{post.user.username}) is not bob"
    assert_equal @alice, Post.last.original_user, "Original user (#{post.original_user.username}) is not alice"

    assert_text "Post #1"
    assert_text "Reposted by @#{@bob.username}"
    
    reset!
    
    login_as(@alice, scope: :user, run_callbacks: false)
    
    visit "/notifications"
    
    assert_text "#{@bob.display_name} reposted your post: \"Post #1\""
  end
  
  test "Repost a post with comment" do
    login_as(@alice, scope: :user, run_callbacks: false)
    
    visit "/"
    
    within("#new_post") do
      fill_in "post[content]", with: "Post #1"
    end
    click_on "Post"
    
    assert_text "Post #1"
    
    reset!
    
    @bob.follow(@alice.username)
    login_as(@bob, scope: :user, run_callbacks: false)
    
    visit "/"
    
    assert_text "Bob"
    
    post = Post.last

    within "#post-row-#{post.id}" do
      click_on "Repost"
    end
    
    assert_text "Add message to repost"
    assert_equal post.id.to_s, find('#repostModal [name="original_post_id"]', visible: false).value

    within "#repostModal" do
      fill_in "post[content]", with: "I reposted Post #1"
      click_on "Repost"
    end
    
    post = Post.last
    
    assert_equal @bob, post.user, "User (#{Post.last.user.username}) is not bob"
    assert_equal @alice, post.original_user, "Original user (#{Post.last.original_user.username}) is not alice"

    assert_text "I reposted Post #1"
    assert_equal @alice.display_name, find("#post-row-#{post.id} blockquote footer").text
    
    reset!
    
    login_as(@alice, scope: :user, run_callbacks: false)
    
    visit "/notifications"
    
    assert_text "#{@bob.display_name} reposted your post: \"Post #1\""
  end
  
  test "Like a post" do
    login_as(@alice, scope: :user, run_callbacks: false)
    
    visit "/"
    
    within("#new_post") do
      fill_in "post[content]", with: "Post #1"
    end
    click_on "Post"
    
    assert_text "Post #1"
    
    reset!
    
    @bob.follow(@alice.username)
    login_as(@bob, scope: :user, run_callbacks: false)
    
    visit "/"
    
    assert_text "Bob"
    
    post = Post.last

    within "#post-row-#{post.id}" do
      click_on "Like"
    end
    
    reset!
    
    login_as(@alice, scope: :user, run_callbacks: false)
    
    visit "/notifications"
    
    assert_text "#{@bob.display_name} liked your post: \"Post #1\""
  end
  
  test "Follow someone" do
    login_as(@alice, scope: :user, run_callbacks: false)
    
    visit "/u/#{@bob.username}"
    
    within ".panel.profile" do
      click_on "Follow"
      assert_text "Following"
    end
    
    reset!
   
    login_as(@bob, scope: :user, run_callbacks: false)
   
    visit "/notifications"
   
    assert_text "#{@alice.display_name} followed you"
    
    assert_equal 1, User.find_by(username: "bob").followers_count
    assert_equal 1, User.find_by(username: "alice").following_count
  end
  
  test "Mention someone" do
    login_as(@alice, scope: :user, run_callbacks: false)

    visit "/"

    within("#new_post") do
      fill_in "post[content]", with: "Hello @#{@bob.username}"
    end
    click_on "Post"

    reset!

    login_as(@bob, scope: :user, run_callbacks: false)

    visit "/notifications"

    assert_text "#{@alice.display_name} mentioned you"
  end
end
