library(mongolite)
library(twitteR)
#https://datascienceplus.com/using-mongodb-with-r/
#http://www.rdatamining.com/docs/twitter-analysis-with-r

library(ROAuth)


#source('APIcodes.R')
consumer_key <- '####'
consumer_secret <- '####'
access_token <- '####'
access_secret <- '####'


## Twitter authentication
setup_twitter_oauth(consumer_key, consumer_secret, access_token,
                    access_secret)
## 3200 is the maximum to retrieve
toxicwaste <- userTimeline("realDonaldTrump", n = 3200)

tweets  <- searchTwitter('#datascience',n=10000, since='2018-03-25',until='2018-03-28')
# convert tweets to a data frame
tweets.df <- twListToDF(tweets)

#Create MongoDB database
#Make sure MongoDB installed and execute mongod app
my_collection = mongo(collection = "tweets", db = "datatweets") # create connection, database and collection
my_collection$insert(tweets.df)

