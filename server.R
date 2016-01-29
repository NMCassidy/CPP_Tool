library(shiny)
library(ggplot2)
library(reshape2)
pcchange=function(x,lag=1) c(rep(0,lag),diff(x,lag))/x

shinyServer(
  function(input,output){
    
    
    jsa_dta<- read.csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_1_1.data.csv?geography=1879048541...1879048572&date=latestMINUS5-latest&sex=7&item=1&measures=20100,20203&select=date_name,geography_name,geography_code,sex_name,item_name,measures_name,obs_value,obs_status_name")
    AC_dta<-subset(jsa_dta, subset = GEOGRAPHY_NAME == "Aberdeen City") 
    AC_tot<-subset(AC_dta, subset = MEASURES_NAME == "Persons claiming JSA", select = c(1,2,6,7))
    jsa_sco<-read.csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_1_1.data.csv?geography=2092957701&date=latestMINUS5-latest&sex=7&item=1&measures=20100,20203&select=date_name,geography_name,geography_code,sex_name,item_name,measures_name,obs_value,obs_status_name")
    sco_tot<-subset(jsa_sco, subset = MEASURES_NAME == "Persons claiming JSA", select=c(1,2,6,7))
    AC_tot$relchange<-pcchange(AC_tot$OBS_VALUE)
    sco_tot$relchange<-pcchange(sco_tot$OBS_VALUE)
    
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
      abplt<-ggplot(data = AC_tot, aes(x = factor(DATE_NAME,levels = AC_tot$DATE_NAME), y = OBS_VALUE))+
        geom_bar(stat = "identity")+
        theme_bw()+ xlab("Date")+ylab("Number of JSA Claimants")
     abplt
    })
    output$relchange_line<-renderPlot({
      mrg_tot<-rbind(AC_tot, sco_tot) 
      rlplt<-ggplot(data = mrg_tot, aes(x = factor(DATE_NAME,levels = AC_tot$DATE_NAME), y = relchange))+
        geom_smooth(size = 1,aes(colour = GEOGRAPHY_NAME, linetype = GEOGRAPHY_NAME, group = GEOGRAPHY_NAME))+
        theme_bw()+geom_hline(yintercept = 0)+
        scale_colour_manual(name = "Geography",breaks = c("Aberdeen City", "Scotland"), values = c("red", "blue"))+
        scale_linetype_manual(name = "Geography",breaks = c("Aberdeen City", "Scotland"), values = c(1,6))+
        xlab("Date")+ylab("Year-on-year Change")
      rlplt
    })
    
    output$relchange_bar<-renderPlot({
      mrg_tot<-rbind(AC_tot, sco_tot)    
      mrg_tot<-mrg_tot[,c(1,2,5)]
      mrg_tot<-melt(mrg_tot)
      rbplt<-ggplot(data = mrg_tot, aes(x = factor(DATE_NAME,levels = mrg_tot$DATE_NAME), y = value, fill = GEOGRAPHY_NAME))+
        geom_bar(position = "dodge", stat = "identity")+
        theme_bw()+geom_hline(yintercept = 0)+
        xlab("Date")+ylab("Year-on-year Change")
      rbplt
    })
    
    output$totchange_perc<-renderPlot({
      AC_tot$abschange<-c(1:nrow(AC_tot))
      for(i in 1:nrow(AC_tot)){
        AC_tot[i,6]<-AC_tot[i,4]/AC_tot[1,4]*100
      }
      sco_tot$abschange<-c(1:nrow(sco_tot))
      for(i in 1:nrow(sco_tot)){
        sco_tot[i,6]<-sco_tot[i,4]/sco_tot[1,4]*100
      }
      mrg_tot<-rbind(AC_tot, sco_tot)
      tcplt<-ggplot(data = mrg_tot, aes(x = factor(DATE_NAME,levels = AC_tot$DATE_NAME), y = abschange))+
        geom_smooth(size = 1, aes(linetype = GEOGRAPHY_NAME, colour = GEOGRAPHY_NAME, group = GEOGRAPHY_NAME))+
      scale_colour_manual(name = "Geography", breaks = c("Aberdeen City", "Scotland"),values = c("red", "blue"))+
        scale_linetype_manual(name = "Geography", breaks = c("Aberdeen City", "Scotland"),values = c(1,6))+
                theme_bw()+geom_hline(yintercept = 0)+ 
        ylim(60,130)+
        geom_hline(yintercept = 100)+
        xlab("Date")+ylab("Percentage Change")
      return(tcplt)
    })
    
    output$downloadPlot <- downloadHandler(
      filename = function() {paste(input$picname, '.png', sep='') },
      content = function(file) {
        ggsave(file, plot = graph(), device = "png")
      }
    )
  })