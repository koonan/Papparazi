class RelationshipsController < ApplicationController

  def create

    @relationship = current_user.relationships.build(rel_params)

    if @relationship.save
      render 'static_pages/success'
    else
      render 'static_pages/fail'
    end

  end
  def show
  end


  private

  def rel_params
    params.require(:relationship).permit(:followed_id)
  end

end
