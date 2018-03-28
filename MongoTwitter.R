library(mongolite)
library(twitteR)
library(stringi)
library(ROAuth)
library(tm)
###SOURCES###
#https://datascienceplus.com/using-mongodb-with-r/
#http://www.rdatamining.com/docs/twitter-analysis-with-r
#############

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


#MongoDB didn't like something about the encoding of tweets, so changing from mostly UTF8 to ASCII
tweetsfew$text <- stri_enc_toascii(tweetsfew$text)

#Create MongoDB database
#Make sure MongoDB installed and execute mongod app
collection = mongo(collection = "tweets2", db = "datatweets") # create connection, database and collection
collection$insert(tweetsfew)
collection$count()

collection$iterate()$one()
###Is this all we have to do with MongoDB, or are we supposed to query it to find word counts?
###Everything below is just R, not really using the MongoDB I just set up

# build a corpus, and specify the source to be character vectors
myCorpus <- Corpus(VectorSource(tweetsfew$text))

# convert to lower case
myCorpus <- tm_map(myCorpus, content_transformer(tolower))
# remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeURL))
# remove anything other than English letters or space
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))
# remove stopwords #Play around with these later!!!######################
myStopwords <- c(stopwords('english'),"datascience",
                         "we can add whatever other stop words here", "via")
myCorpus <- tm_map(myCorpus, removeWords, myStopwords)
# remove extra whitespace
myCorpus <- tm_map(myCorpus, stripWhitespace)

tdm <- TermDocumentMatrix(myCorpus, control = list(wordLengths = c(1, Inf)))

# inspect frequent words
(freq.terms <- findFreqTerms(tdm, lowfreq = 20))
term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq >= 20)
df <- data.frame(term = names(term.freq), freq = term.freq)

library(ggplot2)
ggplot(df, aes(x=term, y=freq)) + geom_bar(stat="identity") +
  xlab("Terms") + ylab("Count") + coord_flip() +
  theme(axis.text=element_text(size=7))

m <- as.matrix(tdm)
# calculate the frequency of words and sort it by frequency
word.freq <- sort(rowSums(m), decreasing = T)
# colors
pal <- brewer.pal(9, "BuGn")[-(1:4)]

# plot word cloud
library(wordcloud)
wordcloud(words = names(word.freq), freq = word.freq, min.freq = 3,
          random.order = F, colors = pal)
