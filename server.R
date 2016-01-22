library(shiny)
library(ggplot2)
pcchange=function(x,lag=1) c(rep(NA,lag),diff(x,lag))/x
shinyServer(
  function(input,output){
    
   
   jsa_dta<- read.csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_1_1.data.csv?geography=1879048541...1879048572&date=latestMINUS5-latest&sex=7&item=1&measures=20100,20203&select=date_name,geography_name,geography_code,sex_name,item_name,measures_name,obs_value,obs_status_name")
   AC_dta<-subset(jsa_dta, subset = GEOGRAPHY_NAME == "Aberdeen City") 
   AC_tot<-subset(AC_dta, subset = MEASURES_NAME == "Persons claiming JSA", select = c(1,2,6,7))
   
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
    
    output$abschnge_bar<-renderPlot({
      ggplot(data = AC_tot, aes(x = factor(DATE_NAME,levels = AC_tot$DATE_NAME), y = OBS_VALUE))+
        geom_bar(stat = "identity")+
        theme_bw()+ xlab("Date")+ylab("Number of JSA Claimants")
    })
    output$relchange_perc<-renderPlot({
      AC_tot$relchange<-pcchange(AC_tot$OBS_VALUE)
      ggplot(data = AC_tot, aes(x = factor(DATE_NAME,levels = AC_tot$DATE_NAME), y = relchange, group = 1))+
        geom_smooth(size = 2)+theme_bw()+geom_hline(yintercept = 0)+
        xlab("Date")+ylab("Year-on-year Change")
      })
    output$totchange_perc<-renderPlot({
     AC_tot$abschange<-c(1:nrow(AC_tot))
      for(i in 1:nrow(AC_tot)){
       AC_tot[i,6]<-AC_tot[i,4]/AC_tot[1,4]*100
      }
     ggplot(data = AC_tot, aes(x = factor(DATE_NAME,levels = AC_tot$DATE_NAME), y = abschange, group = 1))+
       geom_smooth(size = 1)+theme_bw()+geom_hline(yintercept = 0)+
       xlab("Date")+ylab("Year-on-year Change")+ylim(c(90,110))
    })
    
    output$downloadPlot <- downloadHandler(
      filename = function() {paste(input$picname, '.png', sep='') },
      content = function(file) {
        ggsave(file, plot = graph(), device = "png")
      }
    )
  })