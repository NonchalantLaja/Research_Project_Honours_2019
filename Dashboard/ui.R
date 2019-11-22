library(reticulate)
library(shiny)
library(shinydashboard)



############################################################################# RUN THIS CHUNK FIRST

# Changing the working directory to the source file location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Dataset 1
data <- read.csv('data/sp500_All_alt.csv')
data$Date = as.Date(data$Date)

# Dataset 2
data2 <- read.csv('data/sp500_new2.csv')

comp_names <- unique(data2$Company)


# Model Things
# Gain and fall script
source_python('gain_fall.py')

# The Model
source_python('py_model_script.py')

# EVT tings
#source_python('evt.py')

############################################################################## RUN THIS CHUNK FIRST

# Defining the UI for the application
shinyUI(
  dashboardPage( title = "Stock Dashboard",  skin = "black",
    
    dashboardHeader(title = "S&P 500 Dashboard",
                    
                     dropdownMenu(type = "message", 
                                 messageItem(from = "Update", message = "New Stock Prices", time = "04:20"),
                                 messageItem(from = "Charts", message = "Multiple Chart Options", icon = icon("bar-chart"), time = "29-08-2019")
                                 ),
                    dropdownMenu(type = "notifications", 
                                 notificationItem(text = "New menu items added", icon = icon("dashboard"), status = "success"),
                                 notificationItem(text = "S & P 500 Loading...", icon = icon("warning"), status = "warning")
                                 ),
                    dropdownMenu(type = "tasks", 
                                 taskItem(value = 60, color = "red", "Overall daily loss"),
                                 taskItem(value = 75, color = "green", "Trading Percentage"),
                                 taskItem(value = 60, color = "aqua", "Window period")
                                )
                    
                    
                    
                    ),
    
    
    dashboardSidebar(
      
      sidebarMenu(
        
        sidebarSearchForm("searchTest", "buttonSearch", "Search..."),
        
      menuItem("Visualizations", tabName = "Visualizations", icon = icon("image"), badgeLabel = "new", badgeColor = "green"),
      
      menuItem("Detailed Analysis", tabname = "Detailed", icon = icon("bar-chart"),
               
        menuSubItem("Extreme value Theory", tabName = "EVT", icon = icon("line-chart")),
        menuSubItem("Artificial Neural network", tabName = "ANN", icon = icon("clone")),
        menuSubItem("Model", tabName = "model", icon = icon("cogs"))
        
        ),
      
      menuItem("Raw Data", tabName = "Raw", icon = icon("id-card"), badgeLabel = "new", badgeColor = "green")
      
      #menuItem("Project Proposal", tabName = "pdf", icon = icon("clone"), badgeLabel = "new", badgeColor = "red"),
      
      #radioButtons("comp", "Choose Company", choices = c("AMZN", "TWTR", "PYPL" ), inline = T),
      
      #textInput("text_input", "Search Company Name", value = "TWTR")
    
      )
    
    ),
    
    dashboardBody(
      tabItems(
        tabItem(tabName = "Visualizations",
                
                fluidRow(
                  column(width = 12,
                  valueBox(505, "Companies Involved", icon = icon("info-circle"), color = "green"),
                  valueBoxOutput("chosen"),
                  valueBox("Standard & Poor", "The two founding financial companies", icon = icon("question-circle"), color = "yellow")
                  )
                ),
                
                fluidRow(
                  box(title = "Volume Plot of TWTR", status = "success" , solidHeader = T, plotOutput("volume")),
                  box(title = "Adj Close Plot of TWTR", status = "danger", solidHeader = T, plotOutput("close"))
                        ),
                
                fluidRow(
                  tabBox(
                    tabPanel(title = "Adj Close Plot of AMZN", status = "warning", solidHeader = T, plotOutput("close2")),
                    tabPanel(title = "Another Adj Close Plot", status = "warning", solidHeader = T, plotOutput("close3"))
                  ),
                  tabBox(
                    tabPanel(title = "Choose",
                    selectInput("choose_plot",h2("Select Company to Plot"), choices = comp_names, selected = comp_names[1])),
                    tabPanel(title = "Plot type 1", status = "primary", solidHeader = T, plotOutput("type1"), downloadButton("download_type1", "Download Plot")),
                    tabPanel(title = "Plot type 2", status = "secondary", solidHeader = T, plotOutput("type2"), downloadButton("download_type2", "Download Plot")),
                    tabPanel(title = "Plot type 3", status = "warning", solidHeader = T, plotOutput("type3"), downloadButton("download_type3", "Download Plot"))
                  )
                )
                ),
        tabItem(tabname = "Detailed", h1("Detailed Analysis")
                
        
        ),
        tabItem(tabName = "EVT", h1("Extreme Value Theory"),
                fluidRow(
                  box(title = "EVT Distributions", status = "primary" , solidHeader = T,
                      img(src = 'distribution.png', width = 500, height = 500)
                      ),
                  box(
                    h1("EVT can be classified into 3 major distributions, as the image illustrates"), br(),
                    h1("By choosing the best distribution that fits the data"), br(),
                    h1("Frechet, Gumbell and Weibull distributions ensures that the non normally distributed data is properly analysed")
                  )
                )
        ),
        tabItem(tabName = "ANN", h1("Artificial Neural Network"),
                fluidRow(
                  box(title = "Biological & Artificial Neuron Design", status = "primary" , solidHeader = T,
                      img(src = 'bio_art_neuron.png', width = 500, height = 250)
                  ),
                  box(
                    h2("A biological neuron takes in information via the dendrite for the soma to process before passing it on via the axon."), br(),
                    h2("In the case of the artificial neuron, information is taken in from the input nodes."), br(),
                    h2("The input gets multiplied by the weights to form a weighted sum, which is then fed into the body of the artificial neuron."), br(),
                    h2("Within the body is where the weighted sum is fed into an activation function, the processed information is then passed to the output node.")
                  )
                )

        ),
        tabItem(tabName = "model", h1("Model"),
                fluidRow(
                  infoBox("Predicting Gains and Falls", icon = icon("angle-double-up")),
                  infoBox("Feature Engineering", "Gains and Falls", icon = icon("thumbs-up")),
                  valueBoxOutput("chosen_model")
                ),
                fluidRow(
                  selectInput("choose_comp_model",h3("Select Company"), choices = comp_names, selected = comp_names[1])
                ),
                fluidRow(
                  box(h3("What Happens?"), br(),
                      h3("Based on the company you choose, the automated process involves: ")
                      ),
                  box(h3("Creation of a new feature"), br(),
                      h3("Fitting the data with the best EVT Distribution"), br(),
                      h3("Splitting the data into train and test before feeding into the deep model"), br(),
                      h3("Finally generating an accuracy based on the model's performance")
                      )
                ),
                
                tabsetPanel(type = "tab",
                            tabPanel("auto_run.exe", verbatimTextOutput("model_running")),
                            tabPanel("New Feature Generated", DT::dataTableOutput("new_feature")),
                            tabPanel("DistPlot & EVT: Goodness of fit", 
                                     fluidRow(
                                       box(title = "Distribution Plot", status = "primary", solidHeader = T, plotOutput('distplot')),
                                       box(title = "Goodnest of Fit Table", status = "info", solidHeader = T, verbatimTextOutput("goodness"))
                                       )
                                     ),
                            tabPanel("Model Accuracy", verbatimTextOutput("model_acc"))
                            
                )

        ),
        tabItem(tabName = "Raw", h1("Raw Data"),
                
                fluidRow(
                  infoBox("Companies Involved", 505, icon = icon("bar-chart-o")),
                  infoBox("Dashboard Level", "Standard", icon = icon("thumbs-up"))
                ),
                
                fluidRow(br(), h2("Overview of Datasets Used: "), br()
                ),
                
                tabsetPanel(type = "tab",
                            tabPanel("Dataset 1", DT::dataTableOutput("company_all"), downloadButton("download_data1", "Download Dataset 1")),
                            tabPanel("Summary 1", verbatimTextOutput("summary1"),  downloadButton("download_summary1", "Download Summary 1"))
                            
                            ),
                fluidRow(
                  selectInput("choose_comp_raw",h3("Select Company"), choices = comp_names, selected = comp_names[1])
                ),
                
                tabsetPanel(type = "tab",
                            tabPanel("Dataset 2", DT::dataTableOutput("company_data_table"), downloadButton("download_data2", "Download Dataset 2")),
                            tabPanel("Summary 2", verbatimTextOutput("summary2"),  downloadButton("download_summary2", "Download Summary 2"))
                            )
                
                
        )
        # tabItem(tabName = "pdf", h1("Research Document Proposal"),
        #         tags$iframe(style = "height:500px; width:100%; scrolling = yes", src = "proposal.pdf")
        #       )
      

      )
    )
  )
)


