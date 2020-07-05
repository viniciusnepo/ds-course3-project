setwd("C:/Vinicius/R/Course 3/Project")
library(dplyr)

#loading features names
features_names <- read.table("./data/features.txt", header = FALSE, col.names = c("FeatureId", "Feature"))
features_names <- features_names$Feature
head(features_names)

#loading activity labels
activities_labels <- tbl_df(read.table("./data/activity_labels.txt", header = FALSE, col.names = c("ActivityId", "Activity")))
head(activities_labels)

#loading train datasets
sub_train <- tbl_df(read.table("./data/train/subject_train.txt", header = FALSE, col.names = c("SubjectId")))
X_train <- tbl_df(read.table("./data/train/X_train.txt", header = FALSE, col.names = features_names))
Y_train <- tbl_df(read.table("./data/train/Y_train.txt", header = FALSE, col.names = c("ActivityId")))
temp_train <- cbind(sub_train, Y_train, X_train)
train <- merge(temp_train, activities_labels, by = "ActivityId")
remove("temp_train")

#loading test datasets
sub_test <- tbl_df(read.table("./data/test/subject_test.txt", header = FALSE, col.names = c("SubjectId")))
X_test <- tbl_df(read.table("./data/test/X_test.txt", header = FALSE, col.names = features_names))
Y_test <- tbl_df(read.table("./data/test/Y_test.txt", header = FALSE, col.names = c("ActivityId")))
temp_test <- cbind(sub_test, Y_test, X_test)
test <- merge(temp_test, activities_labels, by = "ActivityId")
remove("temp_test")

#merge the datasets
full_data <- rbind(train, test)

#clean unecessary data from memory
remove("features_names")
remove("activities_labels")

remove("sub_train")
remove("X_train")
remove("Y_train")
remove("train")

remove("sub_test")
remove("X_test")
remove("Y_test")
remove("test")

#select mean and standard deviations
mean_cols <- grep("mean", colnames(full_data))
sd_cols <- grep("std", colnames(full_data))

extracted_data <- full_data %>% select(SubjectId, Activity, mean_cols, sd_cols)

#summarize by Activity and Subject
summarized_data <- extracted_data %>% group_by(SubjectId, Activity) %>% summarize_all(c(mean="mean"))

#write data
write.table(summarized_data, file = "./data/summarized.txt", row.names = FALSE)
