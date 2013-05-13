puts "fuck yeah"
require 'csv'

userTopicList = {}
bartenderTopicList = {}
topicMapList = []

numTopics = 8

topicCounter = Array.new(numTopics, 0)

CSV.foreach("bartenders.csv") do |row|
  user_id = row[0]
  bartender_ids = row.drop(2)

  userTopicList[user_id] = Array.new(numTopics, 0)
  bartender_ids.each do |bid|
    bartenderTopicList[bid] = Array.new(numTopics, 0)

    topicMapList << [user_id, bid, Random.rand(numTopics)]
  end
end

numBartenders = bartenderTopicList.length
# init the distribution matrices
topicMapList.each_with_index do |ubt, idx|
      user = ubt[0] #words
      bartender = ubt[1] #documents
      topic = ubt[2]
     
      topicCounter[topic] = topicCounter[topic] + 1
      userTopicList[user][topic] = userTopicList[user][topic] + 1
      bartenderTopicList[bartender][topic] = bartenderTopicList[bartender][topic] + 1	

     if topicCounter[topic] < 0
	puts "shit is fucked: topic"
	exit
     end	
     if userTopicList[user][topic] < 0
	puts "shit is fucked: userTopic"
     end		
     if bartenderTopicList[bartender][topic] < 0
	puts "shit is fucked: bartenderTopic"
     end	
end
#puts userTopicList.inspect
#exit

alpha = Array.new(numTopics, 10)
beta = 1 #-0.01

(0..20).each do |f|
      topicMapList.each_with_index do |ubt, idx|
      user = ubt[0] #words
      bartender = ubt[1] #documents
      topic = ubt[2]

      topicCounter[topic] = topicCounter[topic] - 1
      userTopicList[user][topic] = userTopicList[user][topic] - 1
      bartenderTopicList[bartender][topic] = bartenderTopicList[bartender][topic] -1

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

	phi[t] = (bartenderTopicList[bartender][topic])
        #phi[t] = (userTopicList[user][topic] + alpha[t]) #* (bartenderTopicList[bartender][topic] + beta)
	#* (bartenderTopicList[bartender][topic] + beta) / Float(topicCounter[t] + beta*numBartenders)

        if t == 0
          phiCum[t] = phi[t]
        else
          phiCum[t] = phiCum[t-1] + phi[t]
        end
      end
      puts phi.inspect
      rando = Random.rand() * phiCum[numTopics-1]
      phiCum.each_with_index do |pc, index| # draw a topic
        if pc > rando
	  #puts pc.inspect
          topic = index # assing topic
          break
        end
      end

	if idx > 10
		break
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
	     end	

      #puts topicCounter.inspect
      #puts userTopicList[user][topic].inspect
      #puts bartenderTopicList[bartender][topic]	.inspect
      if idx < 2
        #puts "Phis for #{idx}"
        #puts phi.inspect
      end

      topicMapList[idx] = ubt
    end

    puts "Done with iteration #{f}"
    puts topicCounter.inspect
  end

  #puts topicCounter.inspect
