module Colormodule
	COLOR00 = "\e[0;30m"
	COLOR01 = "\e[1;30m"
	COLOR10 = "\e[0;31m"
	COLOR11 = "\e[1;31m"
	COLOR20 = "\e[0;32m"
	COLOR21 = "\e[1;32m"
	COLOR30 = "\e[0;33m"
	COLOR31 = "\e[1;33m"
	COLOR40 = "\e[0;34m"
	COLOR41 = "\e[1;34m"
	COLOR50 = "\e[0;35m"
	COLOR51 = "\e[1;35m"
	COLOR60 = "\e[0;36m"
	COLOR61 = "\e[1;36m"
	COLOR70 = "\e[0;37m"
	COLOR71 = "\e[1;37m"
	BACK1 = "\e[101m"
	BACK3 = "\e[104m"
	BACK2 = "\e[40m"
	CLEAR="\e[m"
	def blue
		"#{COLOR40}#{self}#{CLEAR}"
	end
	def bluelight
		"#{COLOR41}#{self}#{CLEAR}"
	end
	def grey
		"#{COLOR01}#{self}#{CLEAR}"
	end
	def grey2
		"#{COLOR71}#{self}#{CLEAR}"
	end
	def orange
		"#{COLOR30}#{self}#{CLEAR}"
	end
	def yellow
		"#{COLOR31}#{self}#{CLEAR}"
	end
	def red
		"#{COLOR10}#{self}#{CLEAR}"
	end
	def redlight
		"#{COLOR11}#{self}#{CLEAR}"
	end
	def green
		"#{COLOR20}#{self}#{CLEAR}"
	end
	def greenlight
		"#{COLOR21}#{self}#{CLEAR}"
	end
	def cyan
		"#{COLOR60}#{self}#{CLEAR}"
	end
	def cyanlight
		"#{COLOR61}#{self}#{CLEAR}"
	end
	def purple
		"#{COLOR50}#{self}#{CLEAR}"
	end
	def purplelight
		"#{COLOR51}#{self}#{CLEAR}"
	end
	def back
		"#{BACK3}#{COLOR40}#{self}#{CLEAR}"
	end
	def back2
		"#{BACK2}#{COLOR11}#{self}#{CLEAR}"
	end
end

module Filemodule
	def triangulate
		@dataloc = nil
		@location = File.expand_path(File.dirname(__FILE__))
		if @location.include?("MyGems/")
			@dataloc = Dir.home + "/slogarc.mrs"
		elsif @location.include?("sandbox/")
			@dataloc = File.expand_path(File.dirname(__FILE__)) + "/slogarc.mrs"
		end
	end
	def savedata(total)
		open(@dataloc + ".temp", 'w'){|f| Marshal.dump(total, f)}
		`mv #{@dataloc}.temp #{@dataloc}`
	end
	def loaddata
		begin
			#YAML.load(File.open("./slogarc.yaml"))
			File.open(@dataloc) {|f| Marshal.load(f)}
		rescue ArgumentError => e
			puts "Could not parse MARSH: #{e.message}"
		end
	end
end
class PrintTemplate
	def initialize(data)
		@data = data
	end
	def style1(data)
	counter = 1
	print "#{" [------------------------------------------------------------------------]".grey}\n"
	data.each do |entry|
		datecol = to_day(entry[:time])
		seastr = String.new
		unless entry[:season].nil?
			unless entry[:season].empty?
				seastr << " S["
				last = entry[:season].pop
				entry[:season].each {|ss| seastr << "#{ss.to_s}|"}
				seastr << "#{last}]"
				entry[:season].push last
			end
		end
		print "#{counter.to_s.concat("- ").rjust(5).grey}"
		print "#{date_title(entry).concat(seastr.grey).ljust(70)}"
		print "#{"[".grey}#{date_string(to_day(entry[:time]),entry[:epis].empty?)}#{"|".concat(entry[:time].strftime("%d/%m/%y")).concat("]").grey}".rjust(50)
		print "\n"
		counter += 1
		unless entry[:epis].nil?
			unless entry[:epis].empty?
				dotting entry[:epis],entry[:last_epis] do |dot|
					print dot
				end
			else
				print "	#{"WATCH ME!".back2}\n" if entry[:season].empty?
			end
		end
	end
	print "#{" [------------------------------------------------------------------------]".grey}\n"
	end
	def to_day(time)
		now = Time.now
		past = time
		day = ((now - past)/86400).round
		day
	end
	def date_title(entry)
		if entry[:epis].empty? && !entry[:season].empty?
			return entry[:title].upcase.grey2
		else
			return entry[:title].upcase.bluelight
		end
	end
	def date_string(day,bool)
		week = day / 7
		if bool
			return "#{week.to_s}W".grey
		end
		if day == 0
			return "TODAY".redlight
		elsif day <= 6
			return "#{day.to_s}".orange
		elsif day <= 13
			return "#{day.to_s}".greenlight
		elsif week <= 4
			return "#{week.to_s}W".cyan
		elsif week > 4
			return "#{week.to_s}W".blue
		end
	end
	def dotting(epis,last)
		pick_color = lambda do |var,rep|
			last ||= []
			answer = last.include? var
			if answer
				return rep.back2
			else
				return rep.orange
			end
		end
		season_partition(epis) do |season|
			string = String.new("").concat("      |-".grey)
			string = (lambda do
				lambda do |p1,p2|
					e1 = [p1,p2].cycle
					partition(season) do |parts|
						e1.next.call(parts)
					end
				end.call(
					lambda do |pp|
						string << pick_color.call(pp.first,pp.first.to_s)
						string<< "#{pick_color.call(pp.last,"-"+pp.last.to_s)}" if pp.size==2
						if pp.size > 2
							temp = pp.drop 1
							lasti = temp.pop
							temp.each {|t| string << pick_color.call(t,".")}
							string << pick_color.call(lasti,lasti.to_s)
						end
						string << " "
					end,
					lambda do |pp|
						str = ""
						str = "#{"-".orange}#{pp.last}" if pp.size == 2
						str = "#{"."*(pp.size - 2)}#{pp.last}" if pp.size> 2
						string << "#{pp.first}#{str}".grey
						string << " "
					end )
			end.call)
			yield string << "\n"
		end
	end
	def season_partition(list)
		temp = []
		last = nil
		list.each do |se|
			se = se.to_i
			if (se / 100) == last
				temp << se
				last = se / 100
			else
				yield temp if last != nil
				temp = []
				temp << se
				last = se / 100
			end
		end
		yield temp if last != nil
	end
	def partition(list)
		temp = []
		list.each_cons(2) do |x|
			c1,c0 = x[1].to_i, x[0].to_i
			c = c1-c0
			if c > 1
				temp << c0
				yield temp if !temp.empty?
				temp = []
				((c0+1)..(c1-1)).each {|xi| temp << xi}
				yield temp
				temp = []
			end
			temp << c0 if c == 1
		end
		temp << list.last.to_i
		yield temp if !temp.empty?
	end
end
class Uredo
		attr_reader :undo, :redo
	def initialize total
		@data = total[0]
		@undo = total[1][0]
		@redo = total[1][1]
		@undo ||= []
		@redo ||= []
	end
	def pushy new, old
		u={}
		u[:new] = new
		u[:old] = old
		#puts "push new last:", u[:new][:epis]
		#puts "push old last:", u[:old][:epis]
		#p u
		@undo.push u
		clear_redo
		undo_size
	end
	def undo_size
		sum = @undo.size - 3
		#puts "sum:", sum
		if sum > 0
			@undo = @undo.drop sum
		end
	end
	def clear_redo
		@redo = []
	end
	def undoing
		if @undo.empty?
			puts $text_base[:undo1]
			return false
		end
		#puts ":each"
		#@undo.each {|yy| puts yy[:old][:epis]}
		u = @undo.pop
		unless u[:new].empty?
		#	pp u
			#p "undo new last:", u[:new][:epis]
			ans =  @data.include? u[:new]
			if ans
				@data.delete u[:new]
			else
				@undo = []
				puts "could not found"
			end
		end
		unless u[:old].empty?
			#p "undo old last:", u[:old][:epis]
			if ans
				@data << u[:old]
				list(Array.new(1,u[:old]))
				puts $text_base[:undo2]
			else
				puts "nothing changed"
			end
		end
		@redo.push u
		#to_s
	end
	def redoing
		if @redo.empty?
			puts $text_base[:undo1]
			return false
		end
		u = @redo.pop
		#p "undo old last:", u[:old][:epis]
		unless u[:old].empty?
		#	p u
			ans =  @data.include? u[:old]
			if ans
				@data.delete u[:old]
			else
				@redo= []
				puts "could not found"
			end
		end
		#data.select {|x| x[:title] == $undo.last[:title]}.each {|x| data.delete x}
		#p "undo new last:", u[:new][:epis]
		unless u[:new].empty?
			if ans
				@data << u[:new]
				list(Array.new(1,u[:new]))
				puts $text_base[:undo2]
			else
				puts "nothing changed"
			end
		end
		@undo.push u
		#to_s
		#allp
	end
	def to_s
		print "undo stack: \n"
		c = 1
		@undo.each do |rt|
			print c,"\n"
			print "  new: ", rt[:new][:epis].to_s,"\n"
			print "  old: ", rt[:old][:epis].to_s,"\n"
			c += 1
		end
		print "redo stack:\n "
		c = 1
		@redo.each do |rt|
			print c,"\n"
			print "  new: ", rt[:new][:epis].to_s,"\n"
			print "  old: ", rt[:old][:epis].to_s,"\n"
			c += 1
		end
	end
end
