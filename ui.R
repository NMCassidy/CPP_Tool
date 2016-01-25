library(shiny)

shinyUI(navbarPage("CPP Performance Reporting",
           mainPanel(p("Welcome to my wonderful SHINY App. Select an option from the drop down list to begin."),br(), p("Obviously I would spend time in here to explain how to use this and what it does. Could include any other text that was needed here.")),
           navbarMenu("A List",
                      tabPanel("One Outcome",tabsetPanel(
                        tabPanel(
                          "BarGraph", plotOutput("graph")),
                        tabPanel("Something Else",strong("something interesting can be in here")),
                        tabPanel("Third Thing", p("maybe target setting or something"))
                      )),
                      tabPanel("Employment - JSA",
                               tabsetPanel(
                        tabPanel("Relative Change Bar Chart", plotOutput("relchange_bar")),
                        tabPanel("Relative Change Line Chart",plotOutput("relchange_line")),
                        tabPanel("Absolute Change Line Chart", plotOutput("totchange_perc"))
                      )),
                      hr(),
                    fluidRow(
                        column(4, 
                               h5("Upload a Dataset"),
                               fileInput("fl", "Upload a Dataset", accept = ".csv")),
                        column(4,
                               h5("Download Image"),
                               textInput("picname", "Plot Title", value = ""),
                               downloadButton('downloadPlot', 'Save Plot'))
                              
                      )
           )))