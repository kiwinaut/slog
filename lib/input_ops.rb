class InputOps
	def prompt(string)
		print "#{string}"
		c = gets.chomp
		c
	end
	def episode_prompt
		epis = prompt(" [episode? ]".grey)
		ep, sea = episode_parse(epis)
		return ep, sea
	end
	def title_prompt
		title = prompt(" title? ]".grey)
		title
	end
	def episode_parse(str)
		epis, sea = [], []
		arr = str.split(',')
		arr.each do |a|
			if a.include?("-")
				rang = a.split('-')
				if !rang[0].nil? && !rang[1].nil?
					if rang.all?{|x| x =~ /S\d{2}/}
						rang.map!{|x| x[1,2]}
						rang.sort!
						var0 = rang[0].to_i
						var1 = rang[1].to_i
						(var0..var1).to_a.each do |var|
							sea << var
						end
					elsif rang.all?{|x| x =~ /^\d+$/}
						rang.sort!
						var0 = rang[0].to_i
						var1 = rang[1].to_i
						(var0..var1).to_a.each do |var|
							epis << var
						end
					end
				else
					puts "fail"
				end
				next
			end
			if a =~ /S\d{2}/
				a = a[1,2].to_i
				sea << a
			elsif a =~ /^\d+$/
				epis << a.to_i
			end
		end
		return epis.uniq.sort, sea.uniq.sort
	end
	def episode_cleaning(entry)
		unless entry[:season].empty? && entry[:epis].nil?
			entry[:season].each do |x|
				entry[:epis] = entry[:epis].find_all {|y| (y / 100) != x}
			end
		end
	end
end
