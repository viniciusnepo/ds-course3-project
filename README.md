# Getting and Cleaning Data Course Project

This repository was created for the Getting and Cleaning Data Course Project. It contains a R source code ("run_analysis.R"), which reads a few text files and tidy it's data into a clean unified dataset.

It was requested that I analysed a few datasets, that contains data collected from accelerometers from the Samsung Galaxy S smartphone. More detailed description on the original data can be found on http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones.

## Contents

  - **run_analysis.R** - It is the source file which process the data
  - **CodeBook.md** - A file containing the tidy dataset variables descriptions
  - **summarized.txt** - The output file from the project
  - *data* folder:
    - *test* folder - Original test data
    - *train* folder - Original train data
    - activity_labels.txt - The activities descriptions
    - features.txt - The features descriptions
    - features_info.txt - Information file on each feature
    - README.txt - Original README from the source

## Step-by-step cleaning process

Here are the steps contained in the **run_analysis.R** source file to get to the desired tidy dataset:

1.  First, you will need to set your working directory to this folder, in order to the script load the data correctly. This is the only input you need to provide:
    ```
    setwd("<your local directory>")
    ```
1.  Afterwards, we load the *dplyr* library:
    ```
    library(dplyr)
    ```
1.  Load the features names:
    ```
    features_names <- read.table("./data/features.txt", header = FALSE, col.names = c("FeatureId", "Feature"))
    features_names <- features_names$Feature
    head(features_names)
    ```
1.  Load the activity labels:
    ```
    activities_labels <- tbl_df(read.table("./data/activity_labels.txt", header = FALSE, col.names = c("ActivityId", "Activity")))
    head(activities_labels)
    ```
1.  After loading the labels, we begin to load the real data, starting with the *train* folder. Here, we load the **X_train** file, using the column names from the **features_names** dataset, created previously. Then, we concatenate the subjects dataset, and merge with the activities dataset, so we can have all the information in a single dataset.
    ```
    sub_train <- tbl_df(read.table("./data/train/subject_train.txt", header = FALSE, col.names = c("SubjectId")))
    X_train <- tbl_df(read.table("./data/train/X_train.txt", header = FALSE, col.names = features_names))
    Y_train <- tbl_df(read.table("./data/train/Y_train.txt", header = FALSE, col.names = c("ActivityId")))
    temp_train <- cbind(sub_train, Y_train, X_train)
    train <- merge(temp_train, activities_labels, by = "ActivityId")
    remove("temp_train")
    ```
1.  And then, we do the same process with the *test* folder:
    ```
    sub_test <- tbl_df(read.table("./data/test/subject_test.txt", header = FALSE, col.names = c("SubjectId")))
    X_test <- tbl_df(read.table("./data/test/X_test.txt", header = FALSE, col.names = features_names))
    Y_test <- tbl_df(read.table("./data/test/Y_test.txt", header = FALSE, col.names = c("ActivityId")))
    temp_test <- cbind(sub_test, Y_test, X_test)
    test <- merge(temp_test, activities_labels, by = "ActivityId")
    remove("temp_test")
    ```
1.  After all the information is loaded, we just need to merge both datasets, as requested:
    ```
    full_data <- rbind(train, test)
    ```
1.  Optionally, I included some code to remove some now unecessary datasets from memory:
    ```
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
    ```
1.  After merging the sets, we were asked to select only the *mean* and *standard deviation* columns from the data. So here, we gather all the columns that match this requirement, and extract into a new dataset:
    ```
    mean_cols <- grep("mean", colnames(full_data))
    sd_cols <- grep("std", colnames(full_data))

    extracted_data <- full_data %>% select(SubjectId, Activity, mean_cols, sd_cols)
    ```
1.  Then, we need to summarize the mean for each variable, by Activity and Subject. We do it with the code:
    ```
    summarized_data <- extracted_data %>% group_by(SubjectId, Activity) %>% summarize_all(c(mean="mean"))
    ```
1.  Now, we just need to write our tidy data into a text file:
    ```
    write.table(summarized_data, file = "./summarized.txt", row.names = FALSE)
    ```