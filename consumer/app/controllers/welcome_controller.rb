class WelcomeController < ApplicationController
  def index
    # cf http://oauth.rubyforge.org/rdoc/classes/OAuth/AccessToken.html
    @consumer_tokens=TestToken.all :conditions=>{:user_id=>current_user.id}
    @token = @consumer_tokens.first.client
    logger.info "private data: "+@token.get("/data/index").body
    render :text => "private data: "+@token.get("/data/index").body
  end
end
