library(shiny)

ui <- fluidPage(
  headerPanel("Tree Analysis"),
  
  sidebarLayout( 
    
    sidebarPanel( 
      
      ###Borough###
      selectInput(inputId = "borough",
                  label = "Which cities have more trees?",
                  choices = list("Bronx" = "Bronx",
                                 "Brooklyn" = "Brooklyn",
                                 "Manhattan" = "Manhattan",
                                 "Queens" = "Queens",  
                                 "Staten Island"="Staten Island")),
      hr(),
      
      
      checkboxGroupInput(inputId = "Curb",
                         label = "Does the tree is ON or OFF the Curb?",
                         choices = list("On Curb" = "OnCurb",
                                        "Off the Curb" = "OffsetFromCurb"
                         )
      ),
      hr(),
      
      checkboxGroupInput(inputId = "Stat",
                         label = "Status of trees",
                         choices = list("Alive"="Alive",
                                        "Dead"="Dead",
                                        "Stump"="Stump")),
      hr(),
      
      checkboxGroupInput(inputId = "healthGraph",
                         label = "Health of trees",
                         choices = list("Good"="Good",
                                        "Fair"="Fair",
                                        "Poor"="Poor")),
      
      hr(),
      
      sliderInput(inputId = "Treediameter",
                  label = "Tree diameter",
                  min = 0,
                  max = 50,
                  value = 50,
                  step = 1),
      hr(),
      
      sliderInput(inputId = "months",label="Month from", min = 1, max = 12, value = 12, step = 1),
      
      hr()),
    mainPanel(
      tabsetPanel(
        tabPanel("Summary", htmlOutput("textDisplay")), 
        tabPanel("Status graph", plotOutput("statusGraph")),
        tabPanel("Health Graph", plotOutput("healthGraph")),
        tabPanel("Top 5 species", plotOutput("topGraph")),
        tabPanel("Tree Map", plotOutput("mapGraph")),
        tabPanel("Number of trees",tableOutput("outTable"))
      ))
    
  ))
