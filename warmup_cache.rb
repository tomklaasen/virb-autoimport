require_relative 'video'

basepath = ARGV[0]
filename = ARGV[1]

if filename.end_with?(".MP4")
	puts "#{filename } is een filmpje"
	video = Video.new(basepath, filename, nil, nil)
	video.duration
	video.video_creation_time
elsif filename.end_with?(".jpg")
	puts "#{filename } is een fotootje"
	video = Video.new(basepath, nil, filename, nil)
	video.photo_creation_time
elsif filename.end_with?(".jpg.processed")
	puts "#{filename } is een verwerkt fotootje"
else 
	puts "onbekende soort file: #{filename}"
end

