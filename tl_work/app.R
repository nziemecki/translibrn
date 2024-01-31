if (!requireNamespace("shiny", quietly = TRUE)) install.packages("shiny")
if (!requireNamespace("shinydashboard", quietly = TRUE)) install.packages("shinydashboard")
if (!requireNamespace("DT", quietly = TRUE)) install.packages("DT")
if (!requireNamespace("shinythemes", quietly = TRUE)) install.packages("shinythemes")
if (!requireNamespace("googlesheets4", quietly = TRUE)) install.packages("googlesheets4")

library(shiny)
library(shinydashboard)
library(DT)
library(googlesheets4)
library(shinythemes)

csv_url <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vQFwgTk5S5GRMDS5ExRFa6wngZQ-DKFh1vedWgC_a370E_xFP7nwALKu7fXyoYxMyEBd-MjtdlXAx79/pub?output=csv"
csv_data <- read.csv(csv_url)

# DATA CLEANUP AND FORMATTING
csv_data$website <- paste0("<a href='", csv_data$website,"' target='_blank'>", csv_data$name,"</a>")
datatable(csv_data, escape = 7)
csv_data[is.na(csv_data)] <- ""

# UI
ui <- fluidPage(theme = shinytheme("cosmo"),
                navbarPage(
                  "Trans Liberation Resource Network",
                  tabPanel("Find Resources",
                           sidebarPanel(
                             width = 4,
                             selectInput("category", "Select Category", c("All", unique(csv_data$single_cat))),
                             tags$hr(),
                             actionButton("load", "Load Data"),
                             
                           ),
                           mainPanel(
                             h2("Relevant Resources"),
                             DTOutput("table")
                           ))))

# Define server logic
server <- function(input, output) {
  data <- reactiveVal(NULL)
  
  observeEvent(input$load, {
    selected_category <- input$category
    
    if (selected_category != "All") {
      filtered_df <- csv_data[csv_data$single_cat == selected_category, ]
      data(filtered_df[, c("name", "address", "email", "phone", "social_media", "donate", "website", "purpose")])
    } else {
      data(csv_data[, c("name", "address", "email", "phone", "social_media", "donate", "website", "purpose")])
    }
  })
  
  output$table <- renderDT({
    req(data())
    
    datatable(data(),
              escape = 7,
              options = list(
                dom = 'Bfrtip',
                buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
                lengthMenu = c(10, 25, 50),
                pageLength = 5,
                ordering = TRUE,
                searching = TRUE,
                responsive = TRUE,
                columnDefs = list(
                  list(className = 'dt-center', targets = '_all'),
                  list(className = 'dt-center', targets = '_all'),
                  list(orderable = FALSE, targets = c(0, 1, 2, 3, 4, 5, 6, 7)),  # Make all columns non-orderable
                  list(visible = FALSE, targets = c(3, 4, 5, 6))
                )
              )
    )  %>%
      formatStyle("website", target = "blank")
  })
  
  observeEvent(input$toggleColumns, {
    # Toggle visibility of hidden columns
    toggleColumns <- c(3, 4, 5, 6)
    colVisibility <- sapply(toggleColumns, function(i) !DT::columnVisible(data(), i))
    colVisibility <- replace(colVisibility, is.na(colVisibility), TRUE)  # Replace NA with TRUE
    datatableProxy("table") %>%
      dataTableAjax(setVisible = list(columns = list(colVisibility = colVisibility)))
  })
}

# Run the Shiny app
shinyApp(ui, server)