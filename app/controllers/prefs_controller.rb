class PrefsController < ApplicationController

  def create

    @pref = current_user.prefs.build(pref_params)
    if (@pref.name != nil)
      @pref.preftype = "celebrity"
      @graph = Koala::Facebook::API.new("EAACEdEose0cBABLPRW84pTBIMSK9w98CZB5rAvKIguX7F6wswEqFACMBWUwGN9GihLY1cmkculMVg1Ndjv6xHC2SGZCP5aEZC6DCmxCu7Cpx1eMqrFa9HrkOYqii6yTz6nbbcZAWgxlZBZAJtHzoPT4qVLgZCkYZAMHpiNUDxlZCnPwedZBoNDjndPToLdUkPTybgZD")
      cele = @graph.search(@pref.name, type: :page).first
      @pref.name = cele["name"]
      @pref.url = cele["id"]

      if @pref.save
        render 'static_pages/success'
      else
        render 'static_pages/fail'
      end
    end

    if @pref.address != nil
      @pref.preftype = "location"
      if !(@pref.longitude == nil || @pref.latitude == nil)
        latitude = @pref.latitude
        longitude = @pref.longitude
        l =[latitude ,longitude]
        query = Geocoder.search(geo_localization).first
        geo_localization = "#{latitude},#{longitude}"
        @pref.loc = l
        @pref.city = query.city
        @pref.country = query.country
        @pref.address = query.address
        if @pref.save
          render 'static_pages/success'
        else
          render 'static_pages/fail'
        end
      else
        arr = Geocoder.coordinates(@pref.address)
        latitude =  arr[0]
        longitude = arr[1]
        l =[latitude ,longitude]
        @pref.loc = l
        @pref.latitude = latitude
        @pref.longitude = longitude
        if @pref.save
          render 'static_pages/success'
        else
          render 'static_pages/fail'
        end
      end

    end

  end

  private
  def pref_params
    params.require(:pref).permit(:name ,:address ,:longitude ,:latitude)
  end
end
