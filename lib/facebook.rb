require 'mechanize'
require 'pp'

module Facebook
  VERSION = "1.5"
  MOBILE_URL = "http://m.facebook.com/"
  SLEEP_TIME = 2 # Conservative?
  USER_AGENT = "iPhone" # Why the hell not?
  # For future (?) localisation 
  STRINGS = {:profile => /Profile/,
             :activity => "Activity",
             :status => "status",
             :photo => "photo",
             :remove_profile => "Remove",
             :wall => "Wall",
             :wall_to_wall => "Wall-to-Wall",
             :unlike => "Unlike",
             :delete_comment => "delete",
             :inbox => "Inbox",
             :delete_msg => "Delete",
             :remove_tag => "remove",
             :notes => /Notes/,
             :delete_note => "Delete",
             :photo_albums => /Photo albums/,
             :photo_delete => "Delete this photo.",
             :events => "Events",
             :past_events => "Past events",
             :remove_event => "Remove Event?"}
  
  class << self
    attr_reader :email, :password
    
    def setup(email, password)
      @email = email
      @password = password
      @a = Mechanize.new { |agent| agent.user_agent_alias = USER_AGENT }
      @profile = nil
      get_home
    end # setup
    
    def delete_wall_items
      puts "Proceeding with deletion of profile items"
      remove_count = nil
      while remove_count != 0 # As long as there are things to remove. Inelegant.
        profile = get_profile
        remove_count = 0 # For the exit condition
        # Is there a more compact way?
        patterns = [STRINGS[:activity],STRINGS[:status],STRINGS[:photo]]
        profile.links.find_all { |l| patterns.include?(l.text) }.each do |link|
          puts "Following link (#{link.text})"
          unlike_and_delete(link)
        end
        # We do an independent loop for the removing, so as to make sure 
        # everything is unliked and deleted first
        profile.links_with(:text => STRINGS[:remove_profile]).each do |link|
          puts "Removing item"
          remove_count = remove_count + 1
          remove(link)
        end
        puts "Moving on to next page..." unless remove_count == 0
      end
      puts "Done with profile items"
    end # delete_profile_items
    
    def delete_inbox_items
      puts "Proceeding with deletion of inbox items"
      delete_count = nil
      while delete_count != 0 # As long as there are things to delete. Inelegant.
        inbox = get_inbox
        delete_count = 0 # For the exit condition
        inbox.links_with(:text => STRINGS[:delete_msg]).each do |link|
          puts "Deleting inbox item"
          delete_count = delete_count + 1
          remove(link)
        end
        puts "Moving on to next page..." unless delete_count == 0
      end
    end # delete_inbox_items
    
    def delete_notes
      puts "Proceeding with deletion of notes"
      delete_count = nil
      while delete_count != 0 # As long as there are things to delete. Inelegant.
        notes = get_notes
        delete_count = 0 # For the exit condition
        notes.links_with(:text => STRINGS[:delete_note]).each do |link|
          puts "Deleting note"
          delete_count = delete_count + 1
          remove(link)
        end
        puts "Moving on to next page..." unless delete_count == 0
      end
    end # delete_notes
    
    def delete_albums_photos
      puts "Proceeding with deletion of photos from albums"
      delete_count = nil
      while delete_count != 0 # As long as there are things to delete. Inelegant.
        delete_count = 0 # For the exit condition
        my_albums = get_my_albums
        my_albums.links_with(:href=>/album.php/).each do |link|
          sleep(SLEEP_TIME)
          album = @a.click(link)
          album.links_with(:href=>/photo.php/).each do |l|
            sleep(SLEEP_TIME)
            photo = @a.click(l)
            unlike_and_delete(nil, photo)
            puts "Deleting photo"
            delete_count = delete_count + 1
            remove(photo.link_with(:text => STRINGS[:photo_delete]))
          end
        end
        puts "Moving on to next page..." unless delete_count == 0
      end
    end # delete_albums_photos
    
    def delete_past_events
      puts "Proceeding with removal of past events"
      remove_count = nil
      while remove_count != 0
        remove_count = 0
        past_events = get_past_events
        past_events.links_with(:href=>/\/event.php/).each do |link|
          sleep(SLEEP_TIME)
          event = @a.click(link)
          puts "Removing event"
          remove_count = remove_count + 1
          remove(event.link_with(:text => STRINGS[:remove_event]))
        end
        puts "Moving on to next page..." unless remove_count == 0
      end
    end # delete_past_events
    
    private
    
    def get_home
      @a.get(MOBILE_URL) do |page|
        sleep(SLEEP_TIME)
        @home = page.form_with(:action => "https://login.facebook.com/login.php?m=m") do |f|
          f.email  = @email
          f.pass = @password
        end.submit
      end
      @home
    end # get_home
    
    def get_profile
      sleep(SLEEP_TIME)
      @profile = @a.click(@home.link_with(:text => STRINGS[:profile]))
      @profile
    end # get_profile
    
    def get_inbox
      sleep(SLEEP_TIME)
      inbox = @a.click(@home.link_with(:text => STRINGS[:inbox]))
      inbox
    end # get_inbox
    
    def get_notes
      @profile = get_profile if @profile == nil # No update needed if we already have it
      sleep(SLEEP_TIME)
      notes = @a.click(@profile.link_with(:text => STRINGS[:notes]))
      notes
    end # get_notes
    
    def get_my_albums
      @profile = get_profile if @profile == nil # No update needed if we already have it
      sleep(SLEEP_TIME)
      my_albums = @a.click(@profile.link_with(:text => STRINGS[:photo_albums]))
    end # get_my_albums
    
    def get_past_events
      sleep(SLEEP_TIME) if @events == nil
      @events = @a.click(@home.link_with(:text => STRINGS[:events])) if @events == nil
      sleep(SLEEP_TIME)
      past_events = @a.click(@events.link_with(:text => STRINGS[:past_events]))
      past_events
    end # get_past_events
    
    def unlike_and_delete(link, page = nil)
      sleep(SLEEP_TIME) unless page != nil
      page = @a.click(link) unless page != nil
      page.links.each do |l|
        t = l.text.strip
        next unless t.length > 0
        if t==STRINGS[:unlike]
          puts "Unliking"
          sleep(SLEEP_TIME)
          @a.click(l)
        elsif t==STRINGS[:delete_comment]
          puts "Deleting comment"
          remove(l)
        end
      end 
    end # unlike_and_delete
    
    def remove(link)
      sleep(SLEEP_TIME)
      remove_confirm = @a.click(link)
      sleep(SLEEP_TIME)
      remove_confirm.forms.first.click_button
    end # remove
    
  end
end # Facebook