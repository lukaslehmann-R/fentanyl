### topic modeling

pacman::p_load(tidyverse, ggplot2, utils, tm, SnowballC, caTools, 
               rpart, topicmodels, tidytext, wordcloud, lexicon, reshape2,
               sentimentr)

fent_ads <- read_csv("data/meta-ad-library-2024-08-30.csv")

fent_ads <- fent_ads %>% 
  distinct(ad_creative_bodies, .keep_all = TRUE)

corpus1 <- Corpus(VectorSource(fent_ads$ad_creative_bodies))

corpus1 <- tm_map(corpus1, tolower)
corpus1 <- tm_map(corpus1, removePunctuation)
#We need to remove stop words to get meaningful results from this exercise. 

corpus1 <- tm_map(corpus1, removeWords, (stopwords("english")))
#We need to clean the words in the corpus further by "stemming" words
#A word like "understand" and "understands" will both become "understand"
corpus1 <- tm_map(corpus1, stemDocument)
#creates a document term matrix, which is necessary for building a topic model
DTM1 <- DocumentTermMatrix(corpus1)
#Here we can see the most frequently used terms
frequent_ge_20 <- findFreqTerms(DTM1, lowfreq = 100)
frequent_ge_20

# Identify rows in DTM with all zeros
empty_docs <- rowSums(as.matrix(DTM1)) == 0

# If there are any empty documents, remove them
if(any(empty_docs)) {
  DTM1 <- DTM1[!empty_docs, ]
}

#Perform LDA topic modeling on a Document-Term Matrix (DTM) with 5 topics
fent_lda1 <- LDA(DTM1, k = 5, control = list(seed = 1234))

#Print the model summary
fent_lda1

# #Convert the model's beta matrix to a tidy format
# fent_topics2 <- tidy(fent_lda1, matrix = "beta")

#Convert the model's beta matrix to a tidy format
fent_topics2 <- tidy(fent_lda1, matrix = "gamma")

topic1 <- fent_topics2 %>%
  filter(topic == 1) %>%
  filter(gamma >= 0.75)

topic2 <- fent_topics2 %>%
  filter(topic == 2) %>%
  filter(gamma >= 0.75)

topic3 <- fent_topics2 %>%
  filter(topic == 3) %>%
  filter(gamma >= 0.75)

topic4 <- fent_topics2 %>%
  filter(topic == 4) %>%
  filter(gamma >= 0.75)

topic5 <- fent_topics2 %>%
  filter(topic == 5) %>%
  filter(gamma >= 0.75)

# Extract the top 10 documents for each topic based on gamma values
top_docs_by_topic <- fent_topics2 %>%
  group_by(topic) %>%
  top_n(10, gamma) %>%    # Select top 10 documents with the highest gamma for each topic
  arrange(topic, desc(gamma))   # Arrange by topic and descending gamma

# Assuming `documents_df` has the document texts and IDs, we can join these with `top_docs_by_topic`
# Replace `document_id_column` with the actual name of the column that contains document IDs in your `documents_df`

# # Join to get the actual text
# top_docs_with_text <- top_docs_by_topic %>%
#   inner_join(documents_df, by = c("document" = "document_id_column")) %>% # join by document IDs
#   select(topic, gamma, document, text)  # Select relevant columns

# View the result
top_docs_with_text



# Convert the model's gamma matrix to a tidy format
fent_topics2 <- tidy(fent_lda1, matrix = "gamma")

# Convert the model's gamma matrix to a tidy format
fent_topics2 <- tidy(fent_lda1, matrix = "beta")

# Add a document ID column that corresponds to the row numbers in the original DTM
fent_topics2 <- fent_topics2 %>%
  mutate(document_id = as.numeric(document))

# Extract the top 10 documents for each topic based on gamma values
top_docs_by_topic <- fent_topics2 %>%
  group_by(topic) %>%
  top_n(10, gamma) %>%    # Select top 10 documents with the highest gamma for each topic
  arrange(topic, desc(gamma))   # Arrange by topic and descending gamma

# Add the original text from fent_ads$ad_creative_bodies to the top documents
top_docs_with_text <- top_docs_by_topic %>%
  mutate(text = fent_ads$ad_creative_bodies[document_id],
         advertiser = fent_ads$page_name[document_id]) %>%  # Extract text based on document_id
  select(topic, gamma, document_id, advertiser, text)  # Select relevant columns

# View the result
top_docs_with_text

write_csv(top_docs_with_text, "top_docs_with_text.csv")

# #BETA VALUES
# 
# topic1 <- fent_topics2 %>%
#   filter(topic == 1) %>%
#   filter(beta >= 0.5)
# 
# topic2 <- fent_topics2 %>%
#   filter(topic == 2) %>%
#   filter(beta >= 0.5)
# 
# topic3 <- fent_topics2 %>%
#   filter(topic == 3) %>%
#   filter(beta >= 0.5)
# 
# topic4 <- fent_topics2 %>%
#   filter(topic == 4) %>%
#   filter(beta >= 0.5)
# 
# topic5 <- fent_topics2 %>%
#   filter(topic == 5) %>%
#   filter(beta >= 0.5)

fent_top_terms1 <- fent_topics2 %>%
  group_by(topic) %>% #Group the terms by topic
  slice_max(beta, n = 10) %>% #Top 10 terms with the highest probabilities
  ungroup() %>% #Remove the grouping attribute from the data frame
  arrange(topic, -beta) #Sort the data frame by topic index and term probability

library(ggtext)
library(topicmodels)

#Reorder the terms within each topic based on their probability (beta) values
fent_top_terms1 %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  #Create a bar plot of the term probabilities for each topic
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE, width = 0.8) +
  scale_fill_manual(values = c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b", "#e377c2")) +
  theme_minimal()+
  #Create separate plots for each topic and adjust the y-axis limits for each plot
  facet_wrap(~ topic, scales = "free", ncol = 2, strip.position = "bottom") +
  theme(strip.background = element_blank(),
        strip.text = element_text(size = 12, face = "bold")) +
  #Apply a custom scale for the y-axis that preserves the within-topic ordering of terms
  scale_y_reordered(expand = c(0, 0)) +
  labs(title = "Top 10 Terms by Topic",
       x = "Term Probability",
       y = NULL,
       caption = "Source: LDA Topic Model")

# Calculate perplexity for different numbers of topics
perplexities <- sapply(2:10, function(k) {
  model <- LDA(DTM1, k = k, control = list(seed = 1234))
  perplexity(model, DTM1)
})

# Plot perplexity
plot(2:10, perplexities, type = "b", xlab = "Number of Topics", ylab = "Perplexity")

perplexities










