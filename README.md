capstoneProject_v0.2.html describes how this model was created 
and this html file was created using the RMarkdown file of the same name

The raw dataset used for this project can be found here
https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip

capstoneProject_v0.2.html describes how this model was created

prepare_data.R uses the raw dataset and makes 3-gram and 2-gram and 1-gram(labelled wordfrequency) tables in a directory labeled "data" 

loadDataVariables.R loads the three datasets from data/ into the environment

predictword.R has a function predictword(word1, word2) which takes two words and outputs the predicted next word
