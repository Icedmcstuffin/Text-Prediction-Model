#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(dplyr)

source("loadDataVariables.R")
source("predictword.R")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Next Word Predictor"),
    
    textInput("userinput", "Type a phrase:"),
    verbatimTextOutput("prediction")
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$prediction <- renderText({
    phrase <- trimws(input$userinput)
    if (nchar(phrase) == 0) return("Type at least 2 words")
    
    words <- unlist(strsplit(tolower(phrase), "\\s+"))
    words <- words[grepl("^[a-z]+$", words)]
    if (length(words) <2) return("Type at least 2 words")
    
    n <- length(words)
    preds <- predictword(words[n-1], words[n])
    paste(preds, collapse = " | ")
  })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
