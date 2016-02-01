library(shiny)

shinyUI(navbarPage("CPP Performance Reporting",theme = "bootstrap.css",
           mainPanel(p("Welcome to the example CPP performance reporting SHINY App. Select an option from the drop down list to begin."),br(), p("Obviously I would spend time in here to explain how to use this and what it does. Could include any other text that was needed here.")),
           navbarMenu("A List",
                      tabPanel("Upload Data",tabsetPanel(
                        tabPanel(
                          "BarGraph", plotOutput("graph")),
                        tabPanel("Something Else",strong("something interesting can be in here")),
                        tabPanel("Third Thing", p("maybe target setting or something"))
                        ),
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
                      ),
                      tabPanel("Economic",
                               tabsetPanel(
                        tabPanel("Employment - JSA",
                               tabsetPanel(
                            tabPanel("Relative Change Bar Chart", plotOutput("relchange_bar")),
                            tabPanel("Relative Change Line Chart",plotOutput("relchange_line")),
                            tabPanel("Absolute Change Line Chart", plotOutput("totchange_perc")),
                            tabPanel("Absolute Change Bar Chart", plotOutput("abschnge_bar"))
                      ),
                      hr(),
                      h3("Jobseeker's Allowance (JSA) is a contributory or income based,
                         taxable benefit. It gives an indication of those who are in the 
                         workforce, currently looking for work. within Aberdeen the JSA 
                         rate has increased recently, while Scotland as a whole has seen 
                         a decline in JSA claimants.")
                      ),
                      tabPanel("Economic Performance",
                               tabsetPanel(
                                 tabPanel("GVA", plotOutput("GVA")),
                                 tabPanel("GVA Change", plotOutput("GVA_change")),
                                 tabPanel("business start-up rates")
                               ),
                               hr(),
                               h3("Aberdeen City has a strong economy.
                                  The downturn in the North Sea oil and gas sector
                                  highlights the need to ensure it remains sustainable."),
                               br(),
                               h4("Probably want to add something about the selected indicators."))
                            ))
    
                   
           )))