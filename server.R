library(shiny)
library(ggplot2)
shinyServer(
  function(input,output){
    
   
   jsa_dta<- read.csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_1_1.data.csv?geography=1879048541...1879048572&date=latestMINUS5-latest&sex=7&item=1&measures=20100,20203&select=date_name,geography_name,geography_code,sex_name,item_name,measures_name,obs_value,obs_status_name")
    data<-reactive({
     File<-input$fl
    if(is.null(File)){
    return(NULL)}
    
    read.csv(File$datapath, header = TRUE)
  })
    
    graph<-reactive({
    ggplot(data = data(), aes(x = Local.Authority, y = Local.Authority.Geographical.Area...2005))+
             geom_bar(stat = "identity")
    })
    
    output$graph<-renderPlot({
      return(graph())
    })
    
    output$downloadPlot <- downloadHandler(
      filename = function() {paste(input$picname, '.png', sep='') },
      content = function(file) {
        ggsave(file, plot = graph(), device = "png")
      }
    )
  })