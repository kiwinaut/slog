require 'rake'
Gem::Specification.new do |s|
	s.name = 'slog'
	s.version = '0.4.1'
	s.date = '2014-09-04'
	s.authors = ['Soni Deni']
	s.summary = %q{Tv show tracker}
	s.platform = Gem::Platform::CURRENT
	#s.files = FileList["lib/*"].to_a
	s.files = ["./lib/color_module.rb", "./lib/input_ops.rb","./lib/hash_operations.rb","./bin/slog"]
	s.executables = ["slog"]
end
