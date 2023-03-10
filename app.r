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
  
  rentals <- reactiveFileReader(1000, session, "datasets/rentals.rds", readRDS)
  
  books <- reactive({
    readRDS("datasets/books.rds")
  })

  ## Functions ----
  ### Login function ----
  logged <- reactiveValues(role="", login="")
  
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
          observe( logged$login <- login )
          
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
      observe( logged$login <- "" )
      output$page <- renderUI(loginPanel)
    }
  })
  
  ### Renting books ----
  observeEvent(input$rentButton, {
    confirmSweetAlert(
      session = session,
      inputId = "rentConfirm",
      title = "Confirm your rental",
      text = paste0('Are you sure you want to rent "', input$toRent, '"?'),
      type = "confirm",
      showCancelButton = F
    )
  })
  
  observeEvent(input$rentConfirm, {
    if (input$rentConfirm) {
      book <- input$toRent
      id <- max(rentals()$ID)+1
      status <- "Waiting for acceptance"
      renter <- logged$login
      
      newRecord <- data.frame(ID=id,
                              Renter=renter,
                              Title=book,
                              Status=status)
      
      df <- rbind(rentals(), newRecord)
      saveRDS(df, "datasets/rentals.rds")
    }
  })
  
  ### Confirming rentals ----
  observeEvent(input$rentalsSet, {
    number <- input$rentalsNumber
    status <- input$rentalsStatus
    
    rents <- rentals() %>%
      mutate( Status = ifelse(ID==number, status, Status) )
    
    saveRDS(rents, "datasets/rentals.rds")
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
  
  ### Librarians adding ----
  observeEvent(input$addLibrarian, {
    id <- max(accounts()$ID)+1
    login <- input$libLogin
    password <- input$libPassword
    role <- "Librarian"
    
    if (login=="" | password=="") {
      html("libresult", "Enter all information")
    } else {
      
      if (login %in% accounts()$Login) {
        html("libresult", "This username is taken")
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
        uiOutput("selectInp"),
        uiOutput("table")
      ),
      
      ### Rentals panel ----
      if (logged$role=="Administrator" | logged$role=="Librarian") {
        tabPanel(
          title = "Rentals",
          uiOutput("rentalsNumber"),
          uiOutput("rentalsStatus"),
          
          actionButton(inputId = "rentalsSet",
                       label = "Set",
                       class = "btn btn-success"),
          
          dataTableOutput("rentalsTable")
        )
      },
      
      ### Users panel ----
      if (logged$role=="Administrator" | logged$role=="Librarian") {
        tabPanel(
          title = "Users",
          includeHTML("www/usersPanel.html"),
          dataTableOutput("usersTable")
        )
      },
      
      ### Librarians panel ----
      if (logged$role=="Administrator") {
        tabPanel(
          title = "Librarians",
          includeHTML("www/librariansPanel.html"),
          dataTableOutput("librariansTable")
        )
      },
      
      tags$script(HTML(includeText("www/js/logoutButton.js")))
    )
  })
  
  # UI segments ----
  ### Select to renting books ----
  output$selectInp <- renderUI({
    titles <- books() %>%
      select(Title) %>%
      unique()
    
    div(
      selectInput(inputId = "toRent",
                  label = "Select book to rent:",
                  choices = titles,
                  selected = "The Changeling"
                  ),
      actionButton(inputId = "rentButton",
                   label = "Rent this book",
                   icon = icon("book"),
                   class = "btn btn-success")
    )
  })
  
  ### Table to renting books ----
  output$table <- renderUI({
    div(
      h3("Your rentings:", style="margin: 0 0 20px 0"),
      dataTableOutput("rentingsTable")
    )
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
              options = list(scrollY="180px"),
              rownames=F,
              selection="single",
              style= "bootstrap")
  })

  ### Rentings table ----
  output$rentingsTable <- renderDT({
    rented <- rentals() %>%
      filter(Renter==logged$login)
    
    datatable(rented,
              options = list(scrollY="190px"),
              rownames=F,
              selection="single",
              style= "bootstrap")
  })
  
  ### Rentals number select ----
  output$rentalsNumber <- renderUI({
    numbers <- rentals() %>%
      filter(Status!="Turned") %>%
      select(ID) %>%
      unique()
    
    selectInput(inputId="rentalsNumber",
                label="Select number of operation",
                choices=numbers,
                selected=numbers[1])
  })
  
  ### Rentals status select ----
  output$rentalsStatus <- renderUI({
    selectInput(inputId="rentalsStatus",
                label="Select status to set",
                choices=c("Rented", "Turned"),
                selected="Rented")
  })
  
  ### Rentals table ----
  output$rentalsTable <- renderDT({
    datatable(rentals(),
              options = list(scrollY="170px"),
              rownames=F,
              selection="single",
              style= "bootstrap")
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
  
  # Starting UI setting ----
  output$page <- renderUI(loginPanel)
}

# Shiny App ----
shinyApp(ui, server)