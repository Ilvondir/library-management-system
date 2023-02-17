# Libraries ----
library(shiny)
library(tidyverse)
library(shinyjs)
library(shinythemes)
library(DT)
library(shinyWidgets)

# Data initialization ----
accounts <- readRDS("datasets/accounts.rds")
books <- readRDS("datasets/books.rds")

# UI ----
ui <- uiOutput("page")

# Server ----
server <- function(input, output, session) {

  ## Functions ----
  ### Login function ----
  logged <- reactiveValues(role="")
  
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
          
          observe( logged$role <- role )
          
          confirmSweetAlert(
            session = session,
            inputId = "info",
            title = "Login was successful!",
            text = paste0("Hello!\nYou have logged in as ", role, "."),
            type = "success",
            showCloseButton = F,
            btn_labels = c("Close", "Ok!")
          )
          
          output$page <- mainPanel
        }
      }
    }
  })
  
  ### Logout functions ----
  observeEvent(input$logoutButton, {
    confirmSweetAlert(
      session = session,
      inputId = "confirm",
      title = "Confirm your choice",
      text = "Do you really want to log out?",
      type = "warning",
      showCancelButton = F
    )
  })
  
  observeEvent(input$confirm, {
    if (input$confirm) {
      observe( logged$role <- "" )
      output$page <- renderUI(loginPanel)
    }
  })
  
  ### Books data table----
  output$booksTable <- renderDT({
    datatable(books,
              options = list(scrollY="400px"),
              rownames=F,
              selection="single",
              style= "bootstrap")
  })
  
  ### Librarians table ----
  output$librariansTable <- renderDT({
    tempUsers <- accounts %>%
      filter(Role=="Librarian")
    
    datatable(tempUsers,
              options = list(scrollY="300px"),
              rownames=F,
              selection="single",
              style= "bootstrap")
  })
  
  ## Pages ----
  ### Login page ----
  loginPanel <- fluidPage( useShinyjs(), includeHTML("www/loginPanel.html") )
  
  ### Navbar page ----
  mainPanel <- renderUI({
    navbarPage(
      title = "Library",
      theme = shinytheme("flatly"),
      
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "css/navbar.css")
      ),
      
      #### Catalog panel ----
      tabPanel(
        title = "Catalog",
        dataTableOutput("booksTable")
      ),
      
      ### Renting panel ----
      tabPanel(
        title = "Renting"
      ),
      
      ### Rentals panel ----
      if (logged$role=="Administrator" | logged$role=="Librarian") {
        tabPanel(
          title = "Rentals"
        )
      },
      
      ### Users panel ----
      if (logged$role=="Administrator" | logged$role=="Librarian") {
        tabPanel(
          title = "Users"
        )
      },
      
      ### Librarians panel ----
      if (logged$role=="Administrator") {
        tabPanel(
          title = "Librarians",
          dataTableOutput("librariansTable")
        )
      },
      
      tags$script(HTML(includeText("www/js/logoutButton.js")))
    )
  })
  
  ## Starting UI setting ----
  output$page <- renderUI(loginPanel)
}

# Shiny App ----
shinyApp(ui, server)