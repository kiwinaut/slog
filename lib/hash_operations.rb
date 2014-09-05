#File.expand_path(__FILE__)
require "input_ops"
require "color_module"
require 'pp'
UNDOLIMIT = 10
class Hash_ops
	include Filemodule
	attr_reader :data, :uredo, :iop, :total
	def initialize
		triangulate
		@total = loaddata
		@data = @total[0]
		@uredo = Uredo.new(@total)
		#@uredo.to_s
		@iop = InputOps.new
		@state = false
	end
	def find(string)
		#	dat.push(entry) if (entry[:title] =~ Regexp.new(string)) != nil
		@data.select {|entry| entry[:title] =~ Regexp.new(string)}
	end
	def newtitle
		title = @iop.title_prompt
		episodes, season = @iop.episode_prompt
		entry = {}
		entry[:title] = title
		entry[:time] = Time.now
		entry[:epis] = episodes
		entry[:season] = season

		entry[:last_epis] = episodes
		entry[:last_season] = season

		@iop.episode_cleaning(entry)

		old = {}
		new = entry_clone entry
		@uredo.pushy new, old

		@data.push(entry)
		changed
	end
	def insert(dom, ep, season)
			old = entry_clone dom

			dom[:last_epis] = ep
			dom[:last_season] = season

			dom[:epis].concat ep
			dom[:epis].uniq!
			dom[:epis].sort!
			dom[:season].concat season
			dom[:season].uniq!
			dom[:season].sort!
			dom[:time] = Time.now

			@iop.episode_cleaning(dom)
			#list(Array.new(1,dom))

			new = entry_clone dom
			@uredo.pushy new, old
			#@uredo.to_s

			#@uredo.allp
			changed
	end
	def save
		if @state
			savedata([@data,[@uredo.undo, @uredo.redo]])
		end
	end
	def extract(dom, ep, season)
			old = entry_clone dom
			dom[:last_epis] = []
			dom[:last_season] = []

			ep.each {|x| dom[:epis].delete(x)}
			season.each{|x| dom[:season].delete(x)}

			new = entry_clone dom
			@uredo.pushy new, old
			changed
	end
	def delete_title(pick)
			#list(Array.new(1,dom))
		confirm = @iop.prompt("Are You Sure/[Y]es? ")
			if confirm == "y"
				## Undo ------------------------------
			old = entry_clone pick
			new = {}
			@uredo.pushy new, old
				## Delete ----------------------------
				@data.delete pick
				puts "DELETED!"
			end
			changed
	end
	def rename_title(picks, data)
		picks.each do |dom|
			#list(Array.new(1,dom))
			new = @iop.prompt("New Title? ")
			unless new == ""
				u={}
				u[:old] = dom.clone
				dom[:title] = new
				puts "CHANGED!"
				u[:new] = dom.clone
				@undo.push(u)
				#list(Array.new(1,dom))
			else
				puts "EMPTY TITLE, TRY AGAIN!"
			end
		end
		savedata(@data)
	end
	def undo
		changed
		@uredo.undoing
	end
	def redo
		changed
		@uredo.redoing
	end
	def changed
		@state = true
	end
	def entry_clone(entry)
		cloned = entry.dup
		cloned[:epis] = entry[:epis].dup unless entry[:epis].nil?
		cloned[:season] = entry[:season].dup unless entry[:season].nil?
		cloned[:last_season] = entry[:last_season].dup unless entry[:last_season].nil?
		cloned[:last_epis] = entry[:last_epis].dup unless entry[:last_epis].nil?
		cloned
	end
	def listundo
		@uredo.undo.each do |yy|
			p yy
		end
	end
end
