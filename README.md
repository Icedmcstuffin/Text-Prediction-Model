capstoneProject_v0.2.html describes how this model was created 
and this html file was created using the RMarkdown file of the same name
The html file can be accessed here https://rpubs.com/IcedMcstuffin/1428801

nextWordPredictor_pitch.html is a page that explains the webapp created for this project via shinyapps and is made from an RMarkdown file of the same name

prepare_data.R uses the raw dataset and makes 3-gram and 2-gram and 1-gram(labelled wordfrequency) tables in a directory labeled "data" 

loadDataVariables.R loads the three datasets from data/ into the environment

predictword.R has a function predictword(word1, word2) which takes two words and outputs the predicted next word


Sources:
The nextWordPredictor app: https://icedmcstuffin.shinyapps.io/nextWordPredictor/
Its code can be accessed in the nextWordPredictor directory

The dataset used to train the model: (https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip)
