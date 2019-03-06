require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  attr_accessor :cookie 

  def initialize(req)
    @req = req 
    if @req.cookies["_rails_lite_app"]
      @cookie = JSON.parse(@req.cookies["_rails_lite_app"], symbolize_names: true)
    else  
      @cookie = {}
    end 
  end

  def [](key) 
    self.cookie[key.to_sym]
  end

  def []=(key, val)
    self.cookie[key.to_sym] = val 
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie("_rails_lite_app", {path: "/", value: @cookie.to_json})
  end
end
