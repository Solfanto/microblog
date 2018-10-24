# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_10_24_003914) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "blocks", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "blocked_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blocked_user_id"], name: "index_blocks_on_blocked_user_id"
    t.index ["user_id"], name: "index_blocks_on_user_id"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "following_id"
    t.boolean "friend", default: false
    t.boolean "mute", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["following_id"], name: "index_follows_on_following_id"
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "hash_tags", force: :cascade do |t|
    t.string "name"
    t.integer "posts_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hash_tags_posts", force: :cascade do |t|
    t.bigint "hash_tag_id"
    t.bigint "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hash_tag_id"], name: "index_hash_tags_posts_on_hash_tag_id"
    t.index ["post_id"], name: "index_hash_tags_posts_on_post_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_likes_on_post_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "mentions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "post_id"
    t.boolean "show_in_timeline", default: true
    t.integer "slot", default: 0, comment: "0,1,2,3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_mentions_on_post_id"
    t.index ["user_id"], name: "index_mentions_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id"
    t.text "message"
    t.string "notification_type", comment: "followed/followed_back/replied/reposted/..."
    t.datetime "read_at"
    t.string "primary_item_type"
    t.bigint "primary_item_id"
    t.string "secondary_item_type"
    t.bigint "secondary_item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["primary_item_type", "primary_item_id"], name: "index_notifications_on_primary_item"
    t.index ["secondary_item_type", "secondary_item_id"], name: "index_notifications_on_secondary_item"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "post_threads", force: :cascade do |t|
    t.jsonb "tree", default: {}, comment: "{\"id\": 1, content: \"\", replies: []}"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "original_user_id"
    t.bigint "user_id"
    t.bigint "original_post_id"
    t.string "username"
    t.string "display_name"
    t.integer "likes_count", default: 0
    t.integer "reposts_count", default: 0
    t.boolean "private", default: false
    t.boolean "repost", default: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "post_thread_id"
    t.index "to_tsvector('english'::regconfig, content)", name: "posts_content_index", using: :gin
    t.index ["original_post_id"], name: "index_posts_on_original_post_id"
    t.index ["original_user_id"], name: "index_posts_on_original_user_id"
    t.index ["post_thread_id"], name: "index_posts_on_post_thread_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "username"
    t.string "display_name"
    t.string "bio"
    t.string "website"
    t.string "city"
    t.integer "followers_count", default: 0
    t.integer "following_count", default: 0
    t.integer "posts_count", default: 0
    t.integer "reposts_count", default: 0
    t.integer "likes_count", default: 0
    t.boolean "private_account", default: false
    t.datetime "banned_at"
    t.integer "medias_count", default: 0
    t.boolean "is_default_username", default: true
    t.integer "unread_notifications_count", default: 0
    t.boolean "email_notifications_enabled", default: true
    t.index "to_tsvector('english'::regconfig, (bio)::text)", name: "users_bio_index", using: :gin
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
