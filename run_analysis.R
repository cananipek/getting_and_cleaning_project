#load reshape package
library(reshape2)

#download + unzip data
filename <- "dataset.zip"
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = filename, method = "curl")
unzip(filename)

#Get features data + convert features into character variable
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

#Extract mean and sd data from features
features_wanted <- grep(".*mean.*|.*std.*", features[,2])
features_names <- features[features_wanted,2]
features_names = gsub('-mean', 'Mean', features_names)
features_names = gsub('-std', 'STD', features_names)
features_names <- gsub('[-()]', '', features_names)

#get training data, only the wanted columns
training <- read.table("UCI HAR Dataset/train/X_train.txt")[features_wanted]
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_subjects, train_activities, training)

#get testing data, only the wanted columns
testing <- read.table("UCI HAR Dataset/test/X_test.txt")[features_wanted]
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subjects, test_activities, testing)

#rbind training and testing data + add column names
all_data <- rbind(train,test)
colnames(all_data) <- c("Subject","Activity",features_names)

#get activity labels
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])

#convert activity and subject into factor variables
all_data$Activity <- factor(all_data$Activity, levels = activity_labels[,1], labels = activity_labels[,2])
all_data$Subject <- as.factor(all_data$Subject)

#convert data into long format, collapse by subject + activity
data.melted <- melt(all_data, id = c("Subject", "Activity"))

#Get the average of each variable for each subject and activity
data.mean <- dcast(data.melted, Subject + Activity ~ variable, mean)

#Write tidy data
write.table(data.mean, "tidyData.txt", row.names = F, quote = F)