require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get new" do
    get new_post_url
    assert_response :success
  end

  test "should create post" do
    assert_difference("Post.count") do
      post posts_url, params: { post: { category_id: @post.category_id, content_ca: @post.content_ca, content_en: @post.content_en, content_es: @post.content_es, content_fr: @post.content_fr, title_ca: @post.title_ca, title_en: @post.title_en, title_es: @post.title_es, title_fr: @post.title_fr, user_id: @post.user_id } }
    end

    assert_redirected_to post_url(Post.last)
  end

  test "should show post" do
    get post_url(@post)
    assert_response :success
  end

  test "should get edit" do
    get edit_post_url(@post)
    assert_response :success
  end

  test "should update post" do
    patch post_url(@post), params: { post: { category_id: @post.category_id, content_ca: @post.content_ca, content_en: @post.content_en, content_es: @post.content_es, content_fr: @post.content_fr, title_ca: @post.title_ca, title_en: @post.title_en, title_es: @post.title_es, title_fr: @post.title_fr, user_id: @post.user_id } }
    assert_redirected_to post_url(@post)
  end

  test "should destroy post" do
    assert_difference("Post.count", -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
  end
end
