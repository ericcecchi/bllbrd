#Written by Mike Worth, http://www.mike-worth.com/2012/06/24/updating-youtube-music-player/
require 'hpricot'
require 'open-uri'

#picks a random mp3 from cwd and plays it
def shuffle
  tracks=Dir['*.mp3']
  if tracks.length==0
    sleep 1
  else
    track=tracks[rand(tracks.length)]
    play(track)
  end
end

#plays the track with mpg321 and tries to look up artist/title details form youtube to print
def play(track)
  begin
    page=Hpricot(open('http://www.youtube.com/watch?v='+track))
    begin
      artist=page.search('span.metadata-info')[0].inner_text.gsub('Artist:','').strip
      title=page.search('span.metadata-info')[1].inner_text.split('"')[1].strip
      track_title=artist+': '+title+'('+track+')'
    rescue
      track_title=page.search('[@id=eow-title]').inner_text.strip.gsub("\n",'')+'('+track+')'
    end
  rescue OpenURI::HTTPError
    track_title=track
  end
  puts 'Playing '+track_title
  $player_pid=IO.popen('mpg321 -q '+ track).pid
  Process.wait($player_pid)
end

#assuming that pid is an instance of mpg321 this will check if it has already been paused and return a boolean
def playing(pid)
  return File.open('/proc/'+$player_pid.to_s+'/stat','r').gets.split(' ')[2]!='T'
end

playlist=Array.new
#This thread actually plays the tracks in the playlist then removes them.
Thread.new{
  while true
    #If the playlist is empty, play random mp3s until someone adds something
    if playlist.length==0 then
      shuffle
    else
      play(playlist.shift)
    end
  end
}

#While the main thread handles the user interface:
while true
  puts 'What would you like to listen to?'
  search_string= gets.chomp

  #allow the use of a few basic commands
  if search_string=='/pause'
    Process.kill('STOP',$player_pid)
  elsif search_string=='/skip'
    Process.kill('KILL',$player_pid)
  elsif search_string=='/play'
    Process.kill('CONT',$player_pid)

  else
    puts'Searching for '+search_string+'...'
    #Use Hpricot to load the youtube search page and scrape the titles and ids of the top 5 results
    begin
      doc = Hpricot(open('http://www.youtube.com/results?search_type=search_videos&search_query='+search_string.gsub(' ','+')))
      result_divs=doc.search('li.result-item-video')
      results=Array.new

      #Ask the user which one they want
      for i in 0..4 do
        #keep the a object as it has both bits of data
        results[i]=result_divs[i].search('a.result-item-translation-title')
        puts (i+1).to_s + ') ' + results[i].inner_text
      end
      choice=gets.chomp.to_i  
      if (1..5).include?(choice) then
        choice-=1
        youtube_id = results[choice].attr('href').split('&#038;')[0].split('=')[1]
    
        #Download/extract the audio in parallel so that more tracks can be added in the meantime
        Thread.new(youtube_id,results[choice].inner_text) {|id,title|
          if ! File.exist?(id+'.mp3')
            puts 'Downloading ' + title
            system('youtube-dl --extract-audio --audio-format mp3 -w -q -f 5 --no-part '+id)
          end
          playlist << id+'.mp3'
          puts title+' added to playlist'
        }
      end
    rescue
      puts 'Error fetching search page'
    end
  end
end