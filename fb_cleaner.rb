#
# Facebook Cleaner
#
# Usage: 
#   ruby fb_cleaner.rb [email [password]]
#
# Requires: mechanize, highline
# Install these by doing: 
#   sudo gem install mechanize highline
#
# Use at you own risk. See LICENSE before any use.
# Check README.md for a few more details.
#

%w{rubygems highline/import lib/facebook}.each{|l| require l}
HighLine.track_eof = false # Bug with Mechanize

abort "#{$0} [email [password]]" if ARGV.size > 2

say("\nFacebook Cleaner v#{Facebook::VERSION} - Use at your own risk\n\n")

case ARGV.size
  when 0
    email = ask("Enter your email:  ")
    password = ask("Enter your password:  ") { |q| q.echo = "*" }
  when 1
    email = ARGV[0]
    password = ask("Enter your password:  ") { |q| q.echo = "*" }
  else
    email = ARGV[0]
    password = ARGV[1]
end

Facebook.setup(email,password)

loop do
  choose do |menu|
    menu.choice :"Delete all wall items\n   (unlike and uncomment when possible)" do
      Facebook.delete_wall_items
      say("Done!")
    end
    menu.choice :"Delete all inbox posts" do
      Facebook.delete_inbox_items
      say("Done!")
    end
    menu.choice :"Delete all notes" do
      Facebook.delete_notes
      say("Done!")
    end
    menu.choice :"Delete all photos from albums\n   (except Profile pictures)" do
      Facebook.delete_albums_photos
      say("Done!")
    end
    menu.choice :"Remove invitations to past events" do
      Facebook.delete_past_events
      say("Done!")
    end
    menu.choice :"Quit" do
      say("Nice doing business with you.")
      exit
    end
  end
end
