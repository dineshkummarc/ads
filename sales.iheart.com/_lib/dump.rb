require 'yaml'

conf = YAML.load_file("_config.yml")
type = ARGV[0]

if type == 'css' || type == 'js'
	conf[type].each do |i|
		print File.open("_site/assets/#{type}/#{i}").read
	end
else
	puts "C'mon, give me something here!"
end
