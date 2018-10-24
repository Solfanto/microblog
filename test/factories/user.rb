# This will guess the User class
FactoryBot.define do
  factory :alice, class: User do
    email { "alice@solfanto.com" }
    username { "alice" }
    display_name { "Alice" }
    password { "aaaaaa" }
    provider { "solfanto_oauth2" }
    is_default_username { false }
  end

  # This will use the User class (Admin would have been guessed)
  factory :bob, class: User do
    email { "bob@solfanto.com" }
    username { "bob" }
    display_name { "Bob" }
    password { "bbbbbb" }
    provider { "solfanto_oauth2" }
    is_default_username { false }
  end
end
