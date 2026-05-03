# Script to prepare necessary dataset

library(tidytext)
library(dplyr)

dir.create("data", showWarnings = FALSE)

# --- Load and sample raw data ---
con <- file("final/en_US/en_US.blogs.txt", "r")
rawblogs <- data.frame(text = readLines(con), source = "blog")
close(con)

con <- file("final/en_US/en_US.news.txt", "r")
rawnews <- data.frame(text = readLines(con), source = "news")
close(con)

con <- file("final/en_US/en_US.twitter.txt", "r")
rawtwitter <- data.frame(text = readLines(con), source = "twitter")
close(con)

rawdata <- bind_rows(rawblogs, rawnews, rawtwitter) %>%
  mutate(id = row_number()) %>%
  select(id, source, text)

rm(rawblogs, rawnews, rawtwitter); gc()

# --- Tokenise ---
tokenblogs <- rawdata %>%
  unnest_tokens(word, input = text) %>%
  filter(grepl("^[a-z]+$", word))

rm(rawdata); gc()

# --- Unigram ---
wordfrequency <- tokenblogs %>% count(word, sort = TRUE)
saveRDS(wordfrequency, "data/wordfrequency.rds")
cat("Saved wordfrequency\n")

# --- Bigram ---
bigramfrequency <- tokenblogs %>%
  group_by(id) %>%
  mutate(nextword = lead(word)) %>%
  filter(!is.na(nextword)) %>%
  mutate(bigram = paste(word, nextword)) %>%
  ungroup() %>%
  count(word, nextword, bigram, sort = TRUE)

saveRDS(bigramfrequency, "data/bigramfrequency.rds")
rm(bigramfrequency); gc()
cat("Saved bigramfrequency\n")

# --- Trigram ---
trigramfrequency <- tokenblogs %>%
  group_by(id) %>%
  mutate(nextword = lead(word), nexttonextword = lead(word, n = 2L)) %>%
  filter(!is.na(nextword), !is.na(nexttonextword)) %>%
  mutate(trigram = paste(word, nextword, nexttonextword)) %>%
  ungroup() %>%
  count(word, nextword, nexttonextword, trigram, sort = TRUE)

saveRDS(trigramfrequency, "data/trigramfrequency.rds")
rm(trigramfrequency); gc()
cat("Saved trigramfrequency\n")

cat("All done! data/ folder is ready.\n")
