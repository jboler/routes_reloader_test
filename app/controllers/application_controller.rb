class ApplicationController < ActionController::Base
  def test
    render plain: 'hi'
  end
end
