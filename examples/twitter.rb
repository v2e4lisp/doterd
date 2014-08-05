require 'doterd'

include Doterd::Autodraw

config { |c|
  c[:dot_filename] = './twitter.dot'
}

at_exit {
  system("open twitter.dot.png")
}


table(:users) {
  id
  name
  email

  created_at
  update_at
}

table(:followings) {
  id
  follower_id
  followee_id

  deleted_at
  created_at
  updated_at
}

table(:likes) {
  id
  tweet_id
  like_by

  created_at
  udpated_at
}

table(:retweets) {
  id
  tweet_id
  retweet_by

  created_at
  udpated_at
}

table(:tweets) {
  id
  user_id
  image_id
  text
  geo String, "some comment"

  created_at "Time", "Comment"
  udpated_at
}

_N_N :users  , :followings
_1_N :users  , :likes
_1_N :users  , :tweets
_1_N :users  , :retweets
_1_N :tweets , :retweets
_1_N :tweets , :likes


