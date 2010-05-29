Facebook Cleaner
================

This script is supposed to basically clean up your Facebook profile.
It's not perfect, and it's inelegant at best.

**USE AT YOUR OWN RISK** - see license before using it!

How do I use it?
----------------

You need to have [mechanize][mechanize] and [highline][highline] installed.

    gem install mechanize highline

(You might need to use sudo.)

Get the project from GitHub (or download the tarball from above): 

    git clone http://github.com/netcrawler/Facebook-Cleaner.git

Change directory, then you can do one of these:

    ruby fb_cleaner.rb my.email@example.com myS3CR3Tpassw0rd
    ruby fb_cleaner.rb my.email@example.com
    ruby fb_cleaner.rb
    
If you do not use the first method, you will be prompted for missing details.
Then, you can choose from a menu what you want to do next.

**Important Note: You need to set your interface to English before using it.** Maybe 
some localisation will be added at some point, but probably not unless someone 
else feels like doing it ;)

How does it work?
-----------------

The script crawls Facebook mobile using [Mechanize][mechanize].

For now, it looks for five things:

- **Wall items**: crawls your wall, finds activity, status, and photo links 
and when possible unlikes them and delete comments. Then it removes all items
from the feed and load the page again until there is nothing left to remove.
- **Inbox messages**: crawls your inbox, delete all messages from the page,
then load the page again until there is nothing left to delete.
- **Notes**: crawls your notes, delete all, etc.
- **Photos from Albums**: cannot delete albums themselves so far...
- **Past events**

Notice 
------

This is by no means a fully effective way to truly delete your data
from the platform. (Is this even possible?) In particular, it will not
delete wall posts from external applications (which do not show up in
the mobile version).

It's just a quickly hacked together way of getting rid of most of your data. 
All improvements are welcome! Fork, fork, fork.

Todo and bugs
-------------

- **TODO:** deleting tags in others' photos
- **TODO:** refactor photo deletion, as it is rather inefficient
- **BUG:** sometimes the script seems to stop and throw a 404. Launching the script 
again seems a good enough BUGFIX for now.

Changelog
---------
- Version 1.5: Delete past events participation. A few bug corrected.
- Version 1.4: Delete photos from albums. Some refactoring using links_with.
- Version 1.3: Notes deletion.
- Version 1.2: Added a HighLine CLI.
- Version 1.1: Refactored and added inbox messages deletion.
- Version 1.0: Basic ugly, functional hack. 


[mechanize]:http://mechanize.rubyforge.org/mechanize/
[highline]:http://highline.rubyforge.org/
