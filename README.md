# Doterd

ruby dsl for erd

## Installation

[graphviz](http://www.graphviz.org/Download_macos.php) should be installed installed.

Add this line to your application's Gemfile:

    gem 'doterd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install doterd


## Usage

see `examples/twitter.rb`

```ruby
require 'doterd'

at_exit {
  system("open twitter.dot.png")
}

include Doterd::Autodraw

config { |c|
  c[:dot_filename] = './twitter.dot'
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
```

![twitter](examples/twitter.dot.png)

