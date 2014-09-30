#!/usr/bin/Rscript
source("R/tweetUtils.R")

print("Reading in data file...")
tweetDf <- getTweetFrameFromCsv()

# let's count the rows (tweets)
print(c(nrow(tweetDf), "tweets in total"))

# print min and max date in nice format
printMinMaxDate(tweetDf)

# find Lady Gaga and Katy Perry mentions:

delaysLG <- getDelayVectorForTerm(tweetDf, "lady gaga")
summary(delaysLG)

delaysKP <- getDelayVectorForTerm(tweetDf, "katy perry")
summary(delaysKP)


pdf("outputHistoLadyGaga.pdf")
hist(delaysLG, breaks=10000, plot=TRUE, xlim=c(0, quantile(delaysLG, 0.8)))
dev.off()

pdf("outputHistoKatyPerry.pdf")
hist(delaysKP, breaks=10000, plot=TRUE, xlim=c(0, quantile(delaysKP, 0.8)))
dev.off()

# aggregate mentions hourly and plot a "trend"

#pdf("outputTrends.pdf")
png(filename="outputTrends.png", width = 600, height = 400, units = "px",pointsize = 16,)
plot2Trends(tweetDf, "lady gaga", "katy perry")
dev.off()
# switch back:
X11()


# hourlyTweetCounts <- aggregateCounts(tweetDf, 3600)
# hourlyLGTweetCounts <- aggregateCountsForTerm(tweetDf, "lady gaga")
# hourlyKPTweetCounts <- aggregateCountsForTerm(tweetDf, "katy perry")
# print("LG")
# print(hourlyLGTweetCounts)
# print("KP")
# print(hourlyKPTweetCounts)


