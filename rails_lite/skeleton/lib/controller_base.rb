require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'active_support/inflector'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    debugger
    @req, @res = req, res
    @already_built_response = false 
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    debugger
    @already_built_response
  end
  
  # Set the response status code and header
  def redirect_to(url)
    debugger
    unless already_built_response?
      @res['Location'] = url
      @res.status = 302
      @already_built_response = true
      @session.store_session(@res)
    else 
      raise("Double Render/Redirect Error")
    end 
  end
  
  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    debugger
    unless already_built_response?
      @res['Content-Type'] = content_type 
      @res.write(content) 
      @already_built_response = true
      @session.store_session(@res)
    else
      raise("Double Render/Redirect Error")
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    debugger
    path = "views/#{self.class.name.underscore}/#{template_name}.html.erb"
    content = File.read(path)
    ivars = grab_ivars(content)
    # template = ERB.new("<%= #{ivars} %>")
    # result = template.result(binding)
    result = ERB.new(content).result(binding)
    render_content(result, 'text/html')
  end

  #helper method for render_template
  def grab_ivars(content)
    ivars = []
    i = 0 
    while i < content.length
      current_char = content[i]
      if current_char == "@"
        ivar = "@"
        j = i + 1
        until content[j] == " " || content[j] == "." || j == content.length
          ivar << content[j]
          j += 1 
        end 
        ivars << ivar 
      end 
      i += 1
    end 
    ivars
  end 

  # method exposing a `Session` object
  def session
    debugger
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

