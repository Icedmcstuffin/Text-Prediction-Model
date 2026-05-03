# Script to prepare necessary dataset

library(tidytext)
library(dplyr)
library(data.table)

dir.create("data", showWarnings = FALSE)

# # --- Load and sample raw data ---
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

# --- Sample BEFORE tokenising ---
set.seed(3223)
rawdata <- rawdata[rbinom(nrow(rawdata), 1, 0.60) == 1, ]  # 60% of lines
cat("Sampled lines:", nrow(rawdata), "\n")

rm(rawblogs, rawnews, rawtwitter); gc()
cat("Raw data loaded and sampled\n")
# --- Tokenise ---
tokenblogs <- rawdata %>%
  unnest_tokens(word, input = text) %>%
  filter(grepl("^[a-z]+$", word))

rm(rawdata); gc()
cat("Dataset tokenised\n")

# --- Unigram ---
wordfrequency <- tokenblogs %>% count(word, sort = TRUE)

wordfrequency <- wordfrequency[c(1:15),]
saveRDS(wordfrequency, "data/wordfrequency.rds")
rm(wordfrequency)
gc()
cat("Saved wordfrequency\n")


# --- Bigram ---
bigramfrequency <- tokenblogs %>%
  group_by(id) %>%
  mutate(nextword = lead(word)) %>%
  filter(!is.na(nextword)) %>%
  mutate(bigram = paste(word, nextword)) %>%
  ungroup() %>%
  count(word, nextword, bigram, sort = TRUE)

bigramfrequency <- as.data.table(bigramfrequency)
# This line keeps only the top 3 prediction for each 2-gram
bigramfrequency <- bigramfrequency[order(-n)][, .SD[1:min(3,.N)], by = .(word)]
bigramfrequency  <- as.data.frame(bigramfrequency)

saveRDS(bigramfrequency, "data/bigramfrequency.rds")
rm(bigramfrequency); gc()
cat("Saved bigramfrequency\n")

# # --- Trigram --- it might take large memory to process this, so it is done in smaller chunks of 1M rows at a time

# Split tokenblogs into chunks and process separately
chunk_size <- 1000000 # 1 million chunks per loop
chunks <- split(tokenblogs, ceiling(seq_len(nrow(tokenblogs)) / chunk_size))
cat("Splitting tokenblogs into", length(chunks), "chunks\n")

trigram_list <- lapply(seq_along(chunks), function(i) {
  cat("Processing chunk", i, "of", length(chunks), "\n")

  result <- chunks[[i]] %>%
    group_by(id) %>%
    mutate(nextword = lead(word), nexttonextword = lead(word, n = 2L)) %>%
    filter(!is.na(nextword), !is.na(nexttonextword)) %>%
    ungroup() %>%
    count(word, nextword, nexttonextword, sort = TRUE)

  cat("Chunk", i, "done:", nrow(result), "trigrams\n")
  return(result)
})

cat("Finished processing all chunks\n")

# Combine chunks and recount
trigramfrequency <- bind_rows(trigram_list) %>%
  group_by(word, nextword, nexttonextword) %>%
  summarise(n = sum(n), .groups = "drop") %>%
  arrange(desc(n))

rm(trigram_list, chunks, tokenblogs); gc()
cat("All chunks combined\n")

# Trim to top 3
trigramfrequency <- as.data.table(trigramfrequency)
cat("Completed converting trigramfrequency to datatable\n")
trigramfrequency <- trigramfrequency[order(-n)][, .SD[1:min(3, .N)], by = .(word, nextword)]
cat("Stripped the datatable to have only top 3 counts of each 3-gram\n")
trigramfrequency <- as.data.frame(trigramfrequency)
cat("Converted trigramfrequency back to dataframe.\nExporting in rds now.\n")

saveRDS(trigramfrequency, "data/trigramfrequency.rds")
rm(trigramfrequency); gc()
cat("Saved trigramfrequency\n")

cat("All done! data/ folder is ready.\n")
