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
server <- function(input, output, session) {
  ## Pages ----
  
  ### Login panel ----
  loginPanel <- fluidPage( useShinyjs(), includeHTML("www/loginPanel.html") )
  
  ### Navbar page ----
  
  
  ### UI setting ----
  output$page <- renderUI(loginPanel)
  
  
  ## Functions ----
  ### Login function ----
  observeEvent(input$loginButton, {
    login <- input$login
    password <- input$password
    
    if (login=="" | password=="") {
      updateTextInput(session, "login", value="")
      updateTextInput(session, "password", value="")
      html("result", "Enter all information")
    } else {
      
      id <- accounts %>%
        filter(login==Login) %>%
        select(ID)
      
      id <- ifelse(nrow(id)==0, -1, id$ID[1])
      
      if (id==-1) {
        updateTextInput(session, "login", value="")
        updateTextInput(session, "password", value="")
        html("result", "User not found")
      } else {
        
        pass <- accounts %>%
          filter(ID==id) %>%
          select(Password)
        
        pass <- pass$Password[1]
        
        if (password!=pass) {
          updateTextInput(session, "login", value="")
          updateTextInput(session, "password", value="")
          html("result", "Wrong password entered")
        } else {
          
          role <- accounts %>%
            filter(ID==id) %>%
            select(Role)
          role <- role$Role[1]
          
          updateTextInput(session, "login", value="")
          updateTextInput(session, "password", value="")
          html("result", "")
          
          showModal(modalDialog(
            title = "Login was successful!",
            paste0("Hello!\nYou have logged in as ", role, ".")
          ))
        }
      }
    }
  })
}

# Shiny App ----
shinyApp(ui, server)