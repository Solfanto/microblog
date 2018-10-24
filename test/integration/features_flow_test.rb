require 'test_helper'

class FeaturesFlowTest < ActionDispatch::IntegrationTest
  test "Publish a post" do
    alice = FactoryBot.create(:alice)
    login_as(alice, scope: :user, run_callbacks: false)
    
    visit "/"
    
    within("#new_post") do
      fill_in "post[content]", with: "Post #1"
    end
    click_on "Post"
    
    assert Post.last.user, alice
    assert_text "Post #1"
  end
  
  test "Repost a post" do
    skip("TODO")
  end
  
  test "Repost a post with comment" do
    skip("TODO")
  end
  
  test "Like a post" do
    skip("TODO")
  end
  
  test "Follow someone" do
    skip("TODO")
  end
  
  test "Mention someone" do
    skip("TODO")
  end
end
