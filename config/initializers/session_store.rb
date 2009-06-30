# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_elections_session',
  :secret      => '27d7dff9e82cb659648585eda19475c2c7f2ad379b0a00bca7d1624ea0c83489bfe53b247c3e23a88fe4974c87699b3bbeb0f1918764c055e9ec8ae094d5bdc7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
