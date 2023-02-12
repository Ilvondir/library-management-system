# Libraries ----
library(shiny)
library(tidyverse)
library(shinyjs)

# Data initialization ----
accounts <- readRDS("datasets/accounts.rds")
books <- readRDS("datasets/books.rds")

# UI ----
ui <- uiOutput("page")

# Server ----
server <- function(input, output) {
  ## Login Panel layout ----
  loginPanel <- fluidPage( useShinyjs(), includeHTML("www/loginPanel.html") )
  output$page <- renderUI(loginPanel)
  
  ## Login function ----
  observeEvent(input$loginButton, {
    login <- input$login
    password <- input$password
    
    
  })
}

# Shiny App ----
shinyApp(ui, server)