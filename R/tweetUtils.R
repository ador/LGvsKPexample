#!/usr/bin/Rscript

getTweetFrameFromCsv <- function(filename="data/LG_vs_KP_oneweek_tweets.csv") {
    # note: without disabling smart quote parsing (without quote= "" param)
    # the file will not be read in entirely becaose of EOF chars in the middle somewhere
    tweetDf <- read.csv(filename, header=TRUE, sep="|",
                    encoding= "utf-8", stringsAsFactors = FALSE, quote = "")
    tweetDf <- tweetDf[order(as.integer(tweetDf$created)), ]
    return(tweetDf)
}

printMinMaxDate <- function(tweetDf) {
    minTimestamp <- min(tweetDf$created)
    maxTimestamp <- max(tweetDf$created)

    minDate <- as.POSIXct(minTimestamp, origin = "1970-01-01", tz = "GMT")
    maxDate <- as.POSIXct(maxTimestamp, origin = "1970-01-01", tz = "GMT")
    print("first tweet is from:")
    print(as.Date(minDate))
    print("last tweet is from:")
    print(as.Date(maxDate))
    print(as.Date(maxDate)-as.Date(minDate))
}

# we could just use the "diff()" built-in function
computeDiffs <- function(timestamps) {
    # create an empty vector
    diffs <- c()
    prevStamp <- timestamps[1]
    for (idx in 2:length(timestamps)) {
        newDiff <- timestamps[idx] - prevStamp
        prevStamp <- timestamps[idx]
        # fill the vector by concatenation
        diffs <- c(diffs, newDiff)
    }
    return(diffs)
}

filterTweetsForTerm <- function(tweetDf, searchTerm, ignore.case=TRUE) {
    # grepl returns a logical vector instead of a list of matching indices
    grepLogicVec <- grepl(searchTerm, tweetDf$text, ignore.case)
    # now we can subset our data frame
    tweetSubset <- tweetDf[grepLogicVec, ]
    return(tweetSubset)
}

getDelayVectorForTerm <- function(tweetDf, searchTerm, ignore.case=TRUE) {
    tweetSubset <- filterTweetsForTerm(tweetDf, searchTerm, ignore.case)
    # let's compute a delay vector of this (with seconds or minutes)
    delayVec <- computeDiffs(tweetSubset$created)
    # or:
    # delayVec <-as.integer(diff(tweetSubset$created))
    return(delayVec)
}

aggregateCounts <- function(tweetDf, seconds) {
    minTimestamp <- min(tweetDf$created)
    # create a new col with the hour value to be aggregated by
    whichHour <- c()
    for (timestamp in tweetDf$created) {
        whichHour <- c(whichHour, floor((timestamp-minTimestamp)/seconds))
    }
    extendedDf <- cbind(tweetDf, whichHour)
    aggr <- aggregate(extendedDf, list(extendedDf$whichHour), FUN=length)
    return(as.vector(aggr$whichHour))
}

aggregateCountsForTerm <- function(tweetDf, searchTerm) {
    selectedDf <- tweetDf[grepl(searchTerm, tweetDf$text, ignore.case=TRUE), ]
    return(aggregateCounts(selectedDf, 3600))
}

plot2Trends <- function(tweetDf, searchTerm1, searchTerm2) {
    # compute hourly activity in vectors
    data1 <- aggregateCountsForTerm(tweetDf, searchTerm1)
    data2 <- aggregateCountsForTerm(tweetDf, searchTerm2)
    # get the range for the x and y axis
    xrange <- range(1:168)
    yrange <- range(0:2000)
    # set up the plot
    plot(xrange, yrange, type="n", xlab="Hours between 2012-02-12 and 2012-02-18 (GMT)",
    ylab="Number of tweets" )
    colors <- rainbow(2)
    linetype <- c(1)
    plotchar <- seq(18,18+2,1)
    # add lines
    lines(1:length(data1), data1, type="l", lwd=1.5,
        lty=linetype[1], col=colors[1], pch=plotchar[1])
    lines(1:length(data2), data2, type="l", lwd=1.5,
        lty=linetype[1], col=colors[2], pch=plotchar[2])

    # add a title and subtitle
    title("Tweet trends", "Lady Gaga vs Katy Perry")

    # add a legend
    legend(xrange[1], yrange[2], c(searchTerm1, searchTerm2), cex=0.8, col=colors,
    pch=plotchar, lty=linetype, title="Tweet")
}

