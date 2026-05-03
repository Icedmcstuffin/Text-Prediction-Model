# Loading all the dataframes in /data

cat("Please wait while we load necessary datasets\n")

wordfrequency <- readRDS("data/wordfrequency.rds")
cat("wordfrequency variable has been loaded.\n")

bigramfrequency <- readRDS("data/bigramfrequency.rds")
cat("bigramfrequency variable has been loaded.\n")

trigramfrequency <- readRDS("data/trigramfrequency.rds")
cat("trigramfrequency variable has been loaded.\n")

cat("Your app is ready to proceed.\n")
