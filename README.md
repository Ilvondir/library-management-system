# Library Management System

This web application is a library management system created using the Shiny framework for the R programming language. When started, the application forces the user to log in to one of the existing accounts. There are three levels of access. Using the application, everyone can browse the library catalog and book a book rent. Librarians can additionally add standard user accounts and must confirm each rent. The administrator can additionally create accounts for new librarians. All datasets are contained in RDS files and are dynamically edited by the application.

## Used Tools

- R 4.2.2
- Shiny 1.7.4
- shinyjs 2.1.0
- shinyWidgets 0.7.6
- shinythemes 1.2.0
- tidyverse 1.3.2
- DT 0.27

## Requirements

For running this program you need:

- [R](https://cran.r-project.org/bin/windows/base)
- [RStudio](https://posit.co/downloads) (optional)

## How to run

1. Execute command `git clone https://github.com/Ilvondir/r-library-system`.
2. Open `app.r` at R/RStudio.
3. Install all missing packages.
4. Run app in an external window using the button in the upper right corner of the workspace.
5. Log in to the selected account to discover various functionalities.

| Account       	| Login	      |   Password 	|
|:---------------:|:-----------:|:-----------:|
| User  	        | user      	|  user   	  | 
| Librarian 	    | librarian 	|  librarian  |
| Administrator 	| admin      	|  admin      |


![useCaseDiagram](www/img/useCaseDiagram.png?raw=true)

## First Look

![firstlook](www/img/firstlook.png?raw=true)
