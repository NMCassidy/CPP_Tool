library(shiny)
library(ggplot2)
shinyServer(
  function(input,output){
   
    
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