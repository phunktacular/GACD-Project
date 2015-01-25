# my.dir <- "./coursera/gacd/gacd-project"
# setwd(my.dir)
require(data.table)

## load test and train activity IDs
train.y <- fread("data/train/y_train.txt") # activity ID for train set
test.y <- fread("data/test/y_test.txt")
activity <- fread("data/activity_labels.txt")

## adds a new column with activity names by ID
train.y <- plyr::join(train.y, activity)
test.y <- plyr::join(test.y, activity)

train.s <- fread("data/train/subject_train.txt", header=FALSE) # subject ID
test.s <- fread("data/test/subject_test.txt", header=FALSE)

## load test and train measurements
train.x <- fread("data/train/x_train.csv", header=FALSE)
test.x <- fread("data/test/x_test.csv", header=FALSE)

## combine x and y values
trainset <- cbind(train.y, train.x)
testset <- cbind(test.y, test.x)

## combine the train and test sets
dataset <- rbind(trainset, testset)


## add in the subject data
subjects <- rbind(train.s, test.s)
dataset <- cbind(subjects, dataset)

## rename columns
featnames <- fread("data/features.txt", header=FALSE)
columns <- c("subject.id", "activity.id", "activity", featnames$V2)
setnames(dataset, columns)

## extract the mean and sd for each feature
cols <- grep("subject.id|activity|mean()|std()", names(dataset))
dataset.sub <- dataset[, cols, with=FALSE]

## average each varible by each activity and subject
keycols <- c("subject.id", "activity")
setkeyv(dataset.sub, keycols)
tidydata <- dataset.sub[, lapply(.SD,mean), by=key(dataset.sub)]
tidydata[,activity.id:=NULL]

write.csv(tidydata, file="tidydata.csv")
