puts "fuck yeah"
require 'csv'

userTopicList = {}
bartenderTopicList = {}
bartenderList = {}
topicMapList = []

numTopics = 20
numMult = 10;
topicCounter = Array.new(numTopics, 0)
CSV.foreach("bartenders.csv") do |row|
  user_id = row[0]
  bartenderList[user_id] = row[1]
  bartender_ids = row.drop(2)
  puts bartender_ids.inspect
    
  userTopicList[user_id] = Array.new(numTopics, 0)
  bartender_ids.each do |bid|
	
    bartenderTopicList[bid] = Array.new(numTopics, 0)
    (0..(numMult-1)).each do |f|	
    	topicMapList << [user_id, bid, Random.rand(numTopics)]
    end	
  end
end
puts bartenderList.inspect
#puts topicMapList.inspect
exit
tempCount = 0
numBartenders = bartenderTopicList.length
# init the distribution matrices
topicMapList.each_with_index do |ubt, idx|
      user = ubt[0] #words
      bartender = ubt[1] #documents
      topic = ubt[2]
     
#tempCount = tempCount + 1
      topicCounter[topic] = topicCounter[topic] + 1
      userTopicList[user][topic] = userTopicList[user][topic] + 1
      bartenderTopicList[bartender][topic] = bartenderTopicList[bartender][topic] + 1	
     #puts tempCount.inspect
     if topicCounter[topic] < 0
	puts "shit is fucked: topic bol"
	exit
     end	
     if userTopicList[user][topic] < 0
	puts "shit is fucked: userTopic bol"
     end		
     if bartenderTopicList[bartender][topic] < 0
	puts "shit is fucked: bartenderTopic bol"
     end	
end
#puts userTopicList.inspect
#exit

alpha = Array.new(numTopics, 1)
beta = 0 #-0.01

(0..20).each do |f|
      topicMapList.each_with_index do |ubt, idx|
      user = ubt[0] #words
      bartender = ubt[1] #documents
      topic = ubt[2]

      topicCounter[topic] = topicCounter[topic] - 1
      userTopicList[user][topic] = userTopicList[user][topic] - 1
      bartenderTopicList[bartender][topic] = bartenderTopicList[bartender][topic] -1	
	#puts idx.inspect
           if topicCounter[topic] < 0
		puts "shit is fucked: topic"
		exit
	     end	
	     if userTopicList[user][topic] < 0
		puts "shit is fucked: userTopic"
		exit
	     end		
	     if bartenderTopicList[bartender][topic] < 0
		puts "shit is fucked: bartenderTopic"
		exit
	     end	


      phi = Array.new(numTopics, 0)
      phiCum = Array.new(numTopics, 0)

      (0..numTopics-1).each do |t|

	phi[t] = (bartenderTopicList[bartender][topic] + alpha[t])* (bartenderTopicList[bartender][topic] + beta)/ Float(topicCounter[t] + beta*numBartenders)
        #phi[t] = (userTopicList[user][topic] + alpha[t]) #* (bartenderTopicList[bartender][topic] + beta)
	#* (bartenderTopicList[bartender][topic] + beta) / Float(topicCounter[t] + beta*numBartenders)
	#phi[2] = 200
        if t == 0
          phiCum[t] = phi[t]
        else
          phiCum[t] = phiCum[t-1] + phi[t]
        end
      end
      #puts phi.inspect
      rando = Random.rand() * phiCum[numTopics-1]
      #phiCum.reverse_each_with_index do |pc, index| # draw a topic
      (0..(numTopics-1)).reverse_each do |i|
        if phiCum[i] < rando
	  #puts pc.inspect
          topic = i # assing topic
          break
        end
      end


      ubt[2] = topic
      topicCounter[topic] = topicCounter[topic] + 1
      userTopicList[user][topic] = userTopicList[user][topic] + 1
      bartenderTopicList[bartender][topic] = bartenderTopicList[bartender][topic] + 1
             if topicCounter[topic] < 0
		puts "shit is fucked: topic eol"
		exit
	     end	
	     if userTopicList[user][topic] < 0
		puts "shit is fucked: userTopic eol"
		exit
	     end		
	     if bartenderTopicList[bartender][topic] < 0
		puts "shit is fucked: bartenderTopic eol"
		exit
	     end	

      #puts topicCounter.inspect
      #puts userTopicList[user][topic].inspect
      #puts bartenderTopicList[bartender][topic]	.inspect
      if idx < 1
        #puts "Phis for #{idx}"
        #puts phi.inspect
      end

      topicMapList[idx] = ubt
    end

    puts "Done with iteration #{f}"
    puts topicCounter.inspect
  end

  #puts topicCounter.inspect
