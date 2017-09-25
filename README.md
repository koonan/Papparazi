# README

Social Network that tracks celebrities by their locations.

* Posts hold tags to some public figures and their location, and some attachments (photo/video). 

* Celebrity tag is matched with the facebook-verified-users by Koala-Facebook-API to select the most closed correct name. 

* Location tag is set by a longitude and a latitude, and other details like (country, city, and address)  by the rails geocoder.  

* Every user feed is determined by his friend's posts,  posts that have his current-location, and posts that have tags similar to his preferences from celebrities and locations.

* Its backend is developed by Ruby on Rails and MongoDB. 


 
