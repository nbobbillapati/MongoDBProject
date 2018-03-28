library(mongolite)
library(twitteR)
#https://datascienceplus.com/using-mongodb-with-r/
#http://www.rdatamining.com/docs/twitter-analysis-with-r

library(ROAuth)



consumer_key <- '####'
consumer_secret <- '####'
access_token <- '####'
access_secret <- '####'
#I saved my secrets in APIcodes.R
source('APIcodes.R')

## Twitter authentication
setup_twitter_oauth(consumer_key, consumer_secret, access_token,
                    access_secret)

#Search twitter, restrict to English. Doing just a few tweets to start, will up n one everything
#is working correctly
tweets  <- searchTwitter('#datascience',n=100, since='2018-03-25',until='2018-03-28', lang='en')
# convert tweets to a data frame
tweets.df <- twListToDF(tweets)

#Limit to more interesting columns 
tweetsfew <- tweets.df[c('text','favoriteCount','created','screenName','retweetCount','isRetweet')]


library(stringi)
#MongoDB didn't like something about the encoding of tweets, so changing from mostly UTF8 to ASCII
tweetsfew$text <- stri_enc_toascii(tweetsfew$text)
#Create MongoDB database
#Make sure MongoDB installed and execute mongod app


my_collection = mongo(collection = "tweets", db = "datatweets") # create connection, database and collection
my_collection$insert(tweetsfew)

