##load packages needed for this analysis
library(dplyr)
library(data.table)

##download file and unzip it
setwd("C:/Users/KatG/Desktop/Coursera")
DataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(DataURL, destfile = "dataset.zip")
unzip(zipfile = "dataset.zip", exdir = "cleandata") 

##read features and activity files
features <- read.table("cleandata/UCI HAR Dataset/features.txt", col.names = c("n", "functions"))
activitylabels <- read.table("cleandata/UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))

##read test data frames 
x_test <- read.table("cleandata/UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("cleandata/UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_test <- read.table("cleandata/UCI HAR Dataset/test/subject_test.txt", col.names = "subject")

##read train data frames
x_train <- read.table("cleandata/UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("cleandata/UCI HAR Dataset/train/y_train.txt", col.names = "code")
subject_train <- read.table("cleandata/UCI HAR Dataset/train/subject_train.txt", col.names = "subject")

##merge all the tables into a single data set
testmerge <- cbind(y_test, subject_test, x_test)
trainmerge <- cbind(y_train, subject_train, x_train)
allmerge <- rbind(trainmerge, testmerge)

##extract only means and standard deviations for each measurement
meanstd <- allmerge %>% select(subject, code, contains("mean"), contains("std"))

##rename variables appropriately with descriptive variable names
meanstd$code <- activitylabels[meanstd$code, 2]

names(meanstd)[2] = "activity"
names(meanstd) <- gsub("Acc", "Accelerometer", names(meanstd))
names(meanstd) <- gsub("Gyro", "Gyroscope", names(meanstd))
names(meanstd) <- gsub("BodyBody", "Body", names(meanstd))
names(meanstd) <- gsub("Mag", "Magnitude", names(meanstd))
names(meanstd) <- gsub("^t", "Time", names(meanstd))
names(meanstd) <- gsub("^f", "Frequency", names(meanstd))
names(meanstd) <- gsub("tBody", "Time of Body", names(meanstd))
names(meanstd) <- gsub("-mean()", "Mean", names(meanstd), ignore.case = TRUE)
names(meanstd) <- gsub("std()", "StandardDeviation", names(meanstd), ignore.case = TRUE)
names(meanstd) <- gsub("-freq()", "Frequency", names(meanstd), ignore.case = TRUE)
names(meanstd) <- gsub("angle", "Angle", names(meanstd))
names(meanstd) <- gsub("gravity", "Gravity", names(meanstd))

##create an separate independent tidy data set with the average of each variable per activity and per subject

TidyDataSet <- meanstd %>% group_by(subject, activity)
write.table(TidyDataSet, "tidydata.txt", row.name = FALSE)
