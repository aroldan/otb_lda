topicCounter = Array.new(10){Random.rand(1000)}
puts topicCounter.inspect

topicPopArray = []

topicCounter.each_with_index do |t, idx|
	topicPopArray << [t, idx]
end

topicPopArray.sort! { |a,b| b[0] <=> a[0] }

puts topicPopArray.inspect




def indexes_of_counts(arr)
	popArr = []
	arr.each_with_index do |t, idx|
		popArr << [t, idx]
	end

	popArr.sort! { |a,b| b[0] <=> a[0] }
end
puts indexes_of_counts(topicCounter).inspect

puts topicCounter[0..3].inspect