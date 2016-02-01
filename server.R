library(shiny)
library(ggplot2)
library(reshape2)
library(xlsx)
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
  
    #Can't get read.xlsx to open directly from web for some reason-url is where dl from  
 #url<-"http://ons.gov.uk/ons/rel/regional-accounts/regional-gross-value-added--income-approach-/december-2015/rft-table-1.xls"
   x<-read.xlsx("C:/Users/cassidy.nicholas/Downloads/gvaireferencetablesv2_tcm77-426884.xls", sheetIndex = 4)
   x2<-read.xlsx("C:/Users/cassidy.nicholas/Downloads/gvaireferencetablesv2_tcm77-426884.xls", sheetIndex = 6)
   
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
        geom_line(size = 1,aes(colour = GEOGRAPHY_NAME, linetype = GEOGRAPHY_NAME, group = GEOGRAPHY_NAME))+
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
        geom_line(size = 1, aes(linetype = GEOGRAPHY_NAME, colour = GEOGRAPHY_NAME, group = GEOGRAPHY_NAME))+
      scale_colour_manual(name = "Geography", breaks = c("Aberdeen City", "Scotland"),values = c("red", "blue"))+
        scale_linetype_manual(name = "Geography", breaks = c("Aberdeen City", "Scotland"),values = c(1,6))+
                theme_bw()+
        ylim(60,130)+
        geom_hline(yintercept = 100)+
        xlab("Date")+ylab("Percentage Change")
      return(tcplt)
    })
    
    output$GVA<-renderPlot({
      #extract relevant data
      GVA_dta<-x[c(2,194,214),c(3,21)]
      colnames(GVA_dta)<-c("Geography", "GVA_Value")
      GVS_plt<-ggplot(data = GVA_dta, aes(x = Geography, y = GVA_Value))+geom_bar(stat = "identity", fill = rep("black", 3))+
    theme_bw()+xlab("")+ylab("GVA per Head of Population (£)")+theme()
    GVS_plt
      })
    output$GVA_change<-renderPlot({
      GVA_chng<-x2[c(1,2,194,214),c(3,5:21)]
      colnames(GVA_chng)<-GVA_chng[1,]
      colnames(GVA_chng)[c(1,18)]<-c("Region Name","2014")
      GVA_chng<-GVA_chng[-1,]
      GVA_chng[18]<-as.numeric(as.character(GVA_chng[18][1:3,]))
      GVA_chng_mlt<-melt(GVA_chng, id = "Region Name")
      GVA_chng_plt<-ggplot(data = GVA_chng_mlt, aes(x = variable, y = value))+
        geom_line(size = 1, aes(linetype = `Region Name`, colour = `Region Name`, group = `Region Name`))+
        geom_hline(yintercept = 0)+theme_bw()+
        scale_colour_manual(name = "Region", breaks = c("Aberdeen City and Aberdeenshire","Scotland", "United Kingdom"), values = c("red", "blue", "black"))+
        scale_linetype_manual(name = "Region", breaks = c("Aberdeen City and Aberdeenshire","Scotland", "United Kingdom"), values = c(1, 7, 8))+
        theme(legend.position = "bottom",
              plot.background = element_rect(colour = "black"),
              legend.background = element_rect(colour = "black"))+
        xlab("Year")+ylab("GVA Growth in %")
      GVA_chng_plt
    })
    
    output$downloadPlot <- downloadHandler(
      filename = function() {paste(input$picname, '.png', sep='') },
      content = function(file) {
        ggsave(file, plot = graph(), device = "png")
      }
    )
  })