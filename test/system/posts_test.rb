require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  setup do
    @post = posts(:one)
  end

  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end

  test "should create post" do
    visit posts_url
    click_on "New post"

    fill_in "Category", with: @post.category_id
    fill_in "Content ca", with: @post.content_ca
    fill_in "Content en", with: @post.content_en
    fill_in "Content es", with: @post.content_es
    fill_in "Content fr", with: @post.content_fr
    fill_in "Title ca", with: @post.title_ca
    fill_in "Title en", with: @post.title_en
    fill_in "Title es", with: @post.title_es
    fill_in "Title fr", with: @post.title_fr
    fill_in "User", with: @post.user_id
    click_on "Create Post"

    assert_text "Post was successfully created"
    click_on "Back"
  end

  test "should update Post" do
    visit post_url(@post)
    click_on "Edit this post", match: :first

    fill_in "Category", with: @post.category_id
    fill_in "Content ca", with: @post.content_ca
    fill_in "Content en", with: @post.content_en
    fill_in "Content es", with: @post.content_es
    fill_in "Content fr", with: @post.content_fr
    fill_in "Title ca", with: @post.title_ca
    fill_in "Title en", with: @post.title_en
    fill_in "Title es", with: @post.title_es
    fill_in "Title fr", with: @post.title_fr
    fill_in "User", with: @post.user_id
    click_on "Update Post"

    assert_text "Post was successfully updated"
    click_on "Back"
  end

  test "should destroy Post" do
    visit post_url(@post)
    click_on "Destroy this post", match: :first

    assert_text "Post was successfully destroyed"
  end
end
