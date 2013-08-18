puts "fuck yeah"
require 'csv'

def indexes_of_counts(arr)
  popArr = []
  arr.each_with_index do |t, idx|
    popArr << [t, idx]
  end

  popArr.sort! { |a,b| b[0] <=> a[0] }
end

def indexes_of_values(hsh)
  popArr = []
  hsh.each do |key, value|
    popArr << [key, value]
  end

  popArr.sort! { |a,b| b[1] <=> a[1] }
end

userTopicList = {}
bartenderTopicList = {}
bartenderList = {}
topicMapList = []
tempTop = []

def top_tenders_for_topic(bartenderTopicList, bartenderList, topic_id, num_tenders)
  bartenderCountsForTopic = {}
  bartenderTopicList.each do |tender_id, tender|
    bartenderCountsForTopic[tender_id] = tender[topic_id]
  end

  bartenderPopArrayForTopic = indexes_of_values(bartenderCountsForTopic)
  bartenderPopArrayForTopic[0..num_tenders].each do |b|
    puts bartenderList[b[0]]
  end
end

numTopics = 15
numMult = 20
nEntries = 0
topicCounter = Array.new(numTopics, 0)
## Generates the bar tender list of W[i],D[i],topic[i]  -> topicMapList
# Randomly assigns topics to each bartender
CSV.foreach("bartenders.csv") do |row|
  user_id = row[0]
  bartenderList[user_id] = row[1]
  bartender_ids = row.drop(2)
  puts bartender_ids.inspect

  userTopicList[user_id] = Array.new(numTopics, 0)
  bartender_ids.each do |bid|

    bartenderTopicList[bid] = Array.new(numTopics, 0)
    (0..(numMult-1)).each do |f|
      nEntries = nEntries + 1

      #topicMapList << [user_id, bid, 3]
      topicMapList << [user_id, bid, Random.rand(numTopics)]
    end
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

alpha = Array.new(numTopics, 1)
beta =1  #-0.01
# This is the main loop.
(0..30).each do |f|
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

      phi[t] = Float(userTopicList[user][t] + alpha[t])* Float(bartenderTopicList[bartender][t] + beta)/ Float(topicCounter[t] + beta*numBartenders)
  
  #phi[t] = (bartenderTopicList[bartender][topic] + alpha[t])* (bartenderTopicList[bartender][topic] + beta)/ Float(topicCounter[t] + beta*numBartenders)
      #phi[t] = (bartenderTopicList[bartender][topic])* (bartenderTopicList[bartender][topic])/ Float(topicCounter[t])

      if t == 0
        phiCum[t] = phi[t]
      else
        phiCum[t] = phiCum[t-1] + phi[t]
      end
    end
    if idx == 100
      puts phi.inspect
    end
    #puts phiCum.inspect
    rando = Random.rand() * phiCum[numTopics-1]
    #puts rando.inspect
    #puts phiCum[numTopics-1]
    #phiCum.reverse_each_with_index do |pc, index| # draw a topic
    (0..(numTopics-1)).each do |i|
      if  rando < phiCum[i]
        #puts i.inspect
        #puts pc.inspect
        topic = i # assing topic
        break
      end
    end

    ubt[2] = topic
    #topicMapList[idx] = ubt
    #puts ubt.inspect
    #puts topicMapList[idx].inspect
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
    #puts bartenderTopicList[bartender][topic]  .inspect
    if idx < 1
      #puts "Phis for #{idx}"
      #puts phi.inspect
    end
  end
  puts "Done with iteration #{f}"
  puts topicCounter.inspect

  topicPopArray = indexes_of_counts(topicCounter)
  puts "Popular topics:"
  puts topicPopArray.inspect
  mostPopularTopic = topicPopArray[0][1] # index of most popular topic
  puts "most popular is #{mostPopularTopic}"

  topicPopArray[0..5].each do |t|
    puts "\tTopic #{t}"
    top_tenders_for_topic(bartenderTopicList, bartenderList, t[1], 10)
  end

  bartenderIds = bartenderList.keys()
  def tenders_for_user(userTopicList, bartenderTopicList, bartenderIds, bartenderList, user_id)
    myTopics = userTopicList[user_id]

    myTenders = {}
    bartenderIds.each do |bId|
      myTenders[bId] = 0
    end

    myTopics.each_with_index do |topicScore, topicIndex|
      bartenderIds.each do |bId|
        bt = bartenderTopicList[bId]
        if bt.nil?
          next
        end

        score = bartenderTopicList[bId][topicIndex]
        myTenders[bId] = myTenders[bId] + topicScore * score
      end

    end

    topTendersForMe = indexes_of_values(myTenders)
    topTendersForMe[0..10].each do |b|
      puts bartenderList[b[0]] # todo: dedupe
    end
  end

  tenders_for_user(userTopicList, bartenderTopicList, bartenderIds, bartenderList, "76")

  # bartenderCountsForMostPopularTopic = {}

  # bartenderTopicList.each do |tender_id, tender|
  #   bartenderCountsForMostPopularTopic[tender_id] = tender[mostPopularTopic]
  # end

  # puts bartenderCountsForMostPopularTopic.inspect
  # bartenderPopArrayForTopic = indexes_of_values(bartenderCountsForMostPopularTopic)
  # puts bartenderPopArrayForTopic.inspect
  # bartenderPopArrayForTopic[0..10].each do |b|
  #   puts bartenderList[b[0]]
  # end
  #bartenderPopArrayForTopic = indexes_of_counts(bartenderCountsForMostPopularTopic)
  # bartenderPopArrayForTopic.each do |b|
  #   #puts bartenderList[b[1]]
  # end

end
#puts topicCounter.inspect
