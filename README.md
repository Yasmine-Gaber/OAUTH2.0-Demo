# OAUTH 2.0 Demo

This project was created as part a presentation to demonstrate how OAUTh 2.0 protocol works.
This is based on the following link:
http://unhandledexpression.com/2011/06/02/rails-and-oauth-plugin-part-1-the-provider/
http://unhandledexpression.com/2011/06/28/rails-and-oauth-plugin-part-2-the-consumer/

It uses oauth-plugin gem, available here: https://github.com/pelle/oauth-plugin

Presentation is also available at: http://www.slideshare.net/yasminegaber/oauth20-15028845

## Installation

Tested on Ubuntu OS, Rails 3.0.7 and Ruby 1.9.3
Note: Rails 3.0.7 is the only version that worked without problems with oauth-plugin

### Steps
Starting from a working project, you can apply the following steps to enable OAUTH 2.0 protocol for it:

#### For provider project:
  ```
1- add 'oauth-plugin' in gem file

2- in console:
rails generate oauth_provider oauth

3- in console:
rake db:migrate

4- in config/application.rb
require 'oauth/rack/oauth_filter'
config.middleware.use OAuth::Rack::OAuthFilter

5- in app/models/user.rb
has_many :client_applications
has_many :tokens, :class_name=>"OauthToken",:order=>"authorized_at desc",:include=>[:client_application]

6- in app/controllers/oauth_controller.rb
alias :logged_in? :user_signed_in?
alias :login_required :authenticate_user!
uncomment authenticate_user!

7- in app/controllers/oauth_clients_controller.rb
alias :login_required :authenticate_user!

8- in views/welcome/index.html.erb
uncomment the link
```
#### For consumer project:
```

1- add 'oauth-plugin' in gem file

2- in console:
rails generate oauth_consumer user

3- in console:
rake db:migrate

4- in app/controllers/oauth_consumers_controller.rb
before_filter :login_required, :only=>:index
by
before_filter :authenticate_user!, :only=>:index
uncomment go_back, logged_in? currentuser=, deny_access!

5- in app/models/user.rb:
has_one :test, :class_name=>"TestToken", :dependent=>:destroy

6- register App in provider

7- add key in config/initializers/oauth_consumers.rb

8- Create app/models/test_token.rb
class TestToken < ConsumerToken
  TEST_SETTINGS={
    :site => "http://localhost:3000",
    :request_token_path => "/oauth/request_token",
    :access_token_path => "/oauth/access_token",
    :authorize_path => "/oauth/authorize"
  }
   
  def self.consumer(options={})
    @consumer ||= OAuth::Consumer.new(credentials[:key], credentials[:secret], TEST_SETTINGS.merge(options))
  end
end


9- in welcome_controller
class WelcomeController < ApplicationController
  def index
    # cf http://oauth.rubyforge.org/rdoc/classes/OAuth/AccessToken.html
    @consumer_tokens=TestToken.all :conditions=>{:user_id=>current_user.id}
    @token = @consumer_tokens.first.client
    logger.info "private data: "+@token.get("/data/index").body
    render :text => "private data: "+@token.get("/data/index").body
  end
end
  
```
