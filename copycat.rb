require 'rumouse'

class CopyCat

    def initialize  
        puts 'welcome to copycat.'
        puts 'copycat will record your mouse locations, and play them back.'
        help
        terminal
        puts 'goodbye.'
    end

    def record
        events = []
        input "press 'enter' to begin."
        loop do
            start_time = Time.now 
            command = input "press 'enter' to save the mouse location, or type 'done'."
            break if command =~ /done/
            end_time = Time.now
            events << { event: 'wait', t: end_time - start_time }
            events << { event: 'click', x: mouse.position[:x], y: mouse.position[:y] }
            puts "#{(end_time - start_time).to_s} second wait recorded."
            puts "click at #{mouse.position[:x]}, #{mouse.position[:y]} recorded."
        end
        puts 'recording complete.'
        summarize events
        @recording = events     
    end

    def play
        if @recording
            puts 'staring playback...'
            @recording.each do |e|
                wait e[:t] if e[:event] == 'wait'
                click e[:x], e[:y] if e[:event] == 'click'
            end
            puts 'playback complete.'
        else
            puts 'no loaded recordings to play.'
        end
    end

    def repeat
        if @recording
            count = input('how many times would you like to repeat your recording?').to_i
            delay = input('how many seconds would you like to wait between playbacks?').to_i
            puts "recording will be played back #{count} times with a #{delay} second delay." 
            count.times do |index|
                play
                wait delay unless index == count - 1
            end
            puts 'done repeating recording.'
        else
            puts 'no loaded recordings to repeat.'
        end
    end

    def save
        if @recording
            filename = input 'name your recording.' unless filename
            File.open("recordings/#{filename}.txt", 'w') do |f|
                f.puts @recording.to_s
            end
            puts "recording saved as #{filename}."
        else
            puts 'no loaded recordings to save.'
        end
    end

    def load
        filename = input "what recording would you like to load?" unless filename
        if File.exists? "recordings/#{filename}.txt"
            recording = eval File.open("recordings/#{filename}.txt", 'r').read
            puts 'recording loaded.'
            summarize recording
            @recording = recording
        else
            puts "failed to load: #{filename}"
            show_recordings
        end
    end

    def delete
        filename = input 'what recording would you like to delete?'
        if File.exists? "recordings/#{filename}.txt"
            if input("are you sure you want to delete #{filename}? (y/n)") == 'y'
                File.delete "recordings/#{filename}.txt"
                puts "#{filename} deleted."
            end
        else
            puts "failed to delete: #{filename}"
            show_recordings        
        end
    end

    def summarize(events)
        puts 'this recording will do the following:'
        events.each do |e|
            puts "  wait for #{e[:t]} seconds" if e[:event] == 'wait'
            puts "  click at #{e[:x]}, #{e[:y]}" if e[:event] == 'click'
        end
    end

    def show_recordings
        puts "here is a list of available recordings:"
        Dir.glob('recordings/*').each do |f|
            puts '  ' + f.gsub('recordings/', '').gsub('.txt','')
        end   
    end

    def help
        puts 'here are some things you can do:'
        puts '  record'
        puts '  play'
        puts '  repeat'
        puts '  save'
        puts '  load'
        puts '  delete'
        puts '  help'
        puts '  quit'
    end

    def terminal
        loop do
            allowed_commands = ['record', 'play', 'repeat', 'save', 'load', 'delete', 'quit', 'help']
            command = input('waiting on your command...').downcase
            if allowed_commands.include? command
                return if command == 'quit'
                eval command
            else
                puts command + ' is not a recognized command.'
                help
            end
        end
    end

    def input(message)
        puts message
        gets.chomp
    end

    def mouse
        @mouse ||= RuMouse.new
        @mouse
    end

    def click(x,y)
        puts "  clicking at #{x.to_s}, #{y.to_s}..."
        mouse.click x, y
    end

    def wait(seconds)
        puts "  waiting #{seconds.to_s} seconds..."
        sleep seconds
    end

end

