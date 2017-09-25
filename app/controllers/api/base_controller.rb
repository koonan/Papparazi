class Api::BaseController < ApplicationController

  def respond_with_success(result)
    render :json => result, :status => 200
  end

  def respond_with_error(result)
    render :json => result, :status => 500
  end

  def respond_with_not_found(result)
    render :json => result, :status => 400
  end


end
