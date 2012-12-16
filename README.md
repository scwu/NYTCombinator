A Perl Dancer app that allows you to see past the NYT paywall and take a
quick look at the front page and most popular posts in the past day,
week and month. 

Completely rendered on the page using Ajax to load the body of the
article onto a lightbox I created for it to add an easy reading
environment. 

Features in development:
Statistics on the articles: what do the comments say? What are the most
common words they use -> what are the implications 
routing decisions (no menu bar to popular yet, but you can view it with
localhost/popular) to view those
front-end (I've neglected this)

Things I've done on internally:
Taken a look at the difference between Shared and Emailed and what that
says about each population, lookng at the articles that were popular one
way or another.

This is a Perl app
clone the app, 
cpan install LWP, WWW::Mechanize, Dancer, XML::Simple, HTML::TreeBuilder
run bin/app.pl
and you're dancing :)
