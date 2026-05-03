library(dplyr)

predictword <- function(word1, word2) {
  word1 <- tolower(word1)
  word2 <- tolower(word2)
  
  
  # Trigram check
  result <- trigramfrequency %>%
    filter(word == word1, nextword == word2) %>%
    arrange(desc(n))
  
  if (nrow(result) > 0) {
    return(result$nexttonextword[1:min(3, nrow(result))])
  }
  
  # Backoff to bigram check
  result <- bigramfrequency %>%
    filter(word == word2) %>%
    arrange(desc(n))
  
  if (nrow(result) > 0) {
    return(result$nextword[1:min(3, nrow(result))])
  }
  
  # Backoff to unigram
  return(wordfrequency$word[1:3])
}