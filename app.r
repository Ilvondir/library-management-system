# Libraries ----
library(shiny)
library(tidyverse)
library(shinyjs)
library(shinythemes)
library(DT)
library(shinyWidgets)

# UI ----
ui <- uiOutput("page")

# Server ----
server <- function(input, output, session) {
  
  ## Data initialization ----
  accounts <- reactiveFileReader(1000, session, "datasets/accounts.rds", readRDS)
  
  books <- reactive({
    readRDS("datasets/books.rds")
  })

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
      
      id <- accounts() %>%
        filter(login==Login) %>%
        select(ID)
      
      id <- ifelse(nrow(id)==0, -1, id$ID[1])
      
      if (id==-1) {
        updateTextInput(session, "login", value="")
        updateTextInput(session, "password", value="")
        html("result", "User not found")
      } else {
        
        pass <- accounts() %>%
          filter(ID==id) %>%
          select(Password)
        
        pass <- pass$Password[1]
        
        if (password!=pass) {
          updateTextInput(session, "login", value="")
          updateTextInput(session, "password", value="")
          html("result", "Wrong password entered")
        } else {
          
          role <- accounts() %>%
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
    datatable(books(),
              options = list(scrollY="400px"),
              rownames=F,
              selection="single",
              style= "bootstrap")
  })
  
  ### User table ----
  output$usersTable <- renderDT({
    tempUsers <- accounts() %>%
      filter(Role=="User")
    
    datatable(tempUsers,
              options = list(scrollY="170px"),
              rownames=F,
              selection="single",
              style= "bootstrap")
  })
  
  ### Users adding ----
  observeEvent(input$addUser, {
    id <- max(accounts()$ID)+1
    login <- input$useLogin
    password <- input$usePassword
    role <- "User"
    
    if (login=="" | password=="") {
      html("result", "Enter all information")
    } else {
      
      if (login %in% accounts()$Login) {
        html("result", "This username is taken")
      } else {
        df <- data.frame(ID=id, Login=login, Password=password, Role=role)
        
        newDF <- rbind(accounts(), df)
        
        saveRDS(newDF, "datasets/accounts.rds")
      }
    }
  })
  
  ### Librarians table ----
  output$librariansTable <- renderDT({
    tempUsers <- accounts() %>%
      filter(Role=="Librarian")
    
    datatable(tempUsers,
              options = list(scrollY="170px"),
              rownames=F,
              selection="single",
              style= "bootstrap")
  })
  
  ### Librarians adding ----
  observeEvent(input$addLibrarian, {
    id <- max(accounts()$ID)+1
    login <- input$libLogin
    password <- input$libPassword
    role <- "Librarian"
    
    if (login=="" | password=="") {
      html("result", "Enter all information")
    } else {
      
      if (login %in% accounts()$Login) {
        html("result", "This username is taken")
      } else {
        df <- data.frame(ID=id, Login=login, Password=password, Role=role)
        
        newDF <- rbind(accounts(), df)
        
        saveRDS(newDF, "datasets/accounts.rds")
      }
    }
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
        title = "Renting",
        includeHTML("www/rentingPanel.html")
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
          title = "Users",
          uiOutput("usersPanel"),
          dataTableOutput("usersTable")
        )
      },
      
      ### Librarians panel ----
      if (logged$role=="Administrator") {
        tabPanel(
          title = "Librarians",
          uiOutput("librariansPanel"),
          dataTableOutput("librariansTable")
        )
      },
      
      tags$script(HTML(includeText("www/js/logoutButton.js")))
    )
  })
  
  # UI segments ----
  ### Librarians HTML panel ----
  output$librariansPanel <- renderUI({
    includeHTML("www/librariansPanel.html")
  })
  
  ### Users HTML panel ----
  output$usersPanel <- renderUI({
    includeHTML("www/usersPanel.html")
  })
  
  # Starting UI setting ----
  output$page <- renderUI(loginPanel)
}

# Shiny App ----
shinyApp(ui, server)