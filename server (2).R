library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(tidyverse)
library(sp)
library(rgdal) 
library(raster)
library(data.table)

df<-read.csv('tree.csv')
df<-subset(df, select = c(created_at, tree_dbh, curb_loc, status, health, user_type, spc_common, borough, latitude, longitude))
df$month <- month(as.POSIXlt(df$created_at, format="%m/%d/%y"))

server <-function(input, output) {
  
  ##here we are subsetting the dataset using reactive function - as a result we created a "tree" dataset
  tree <- reactive({
    
    df <- df[df['month'] <= input$months,]
    
    if(class(input$Curb)=="OffsetFromCurb"){
      
      df <- df[df[,"curb_loc"] %in% unlist(input$Curb),]
      
    }
    
    df
    
  })
  
  
  output$outTable <- renderTable({ 
    
    table(df[df[,"borough"] == input$borough & df[,"tree_dbh"] <= input$Treediameter & df[,"curb_loc"] == input$Curb& df[,"month"] == input$months,'status'] )
  })
  
  output$healthGraph <- renderPlot({
    
    newdata<-subset(df, health ==input$healthGraph & input$Treediameter & curb_loc ==input$Curb & month == input$months)
    
    newdata <- newdata %>% group_by(borough,health,user_type,curb_loc) %>%    summarise(num=n())
    
    theGraph <- ggplot(newdata,aes(health,num,fill=user_type)) + geom_col(position = "stack") + facet_wrap(~ borough)+ theme(plot.background = element_rect(fill = "gray0")) +theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()) + theme(axis.text.x = element_text(angle = 40, hjust = 1, colour = 'white'),axis.text.y = element_text(angle = 0, hjust = 1, colour = 'white'))
    
    print(theGraph)
    
  })
  
  output$statusGraph <- renderPlot({
    
    newdata<-subset(df, status==input$Stat & input$Treediameter & curb_loc ==input$Curb& month == input$months)
    
    newdata <- newdata %>% group_by(borough,status,user_type,curb_loc) %>%    summarise(num=n())
    theGraph <- ggplot(newdata,aes(status,num,fill=user_type)) + geom_col(position = "stack") + facet_wrap(~ borough)+theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()) + theme(axis.text.x = element_text(angle = 40, hjust = 1, colour = 'white'),axis.text.y = element_text(angle = 0, hjust = 1, colour = 'white')) + theme(plot.background = element_rect(fill = "gray0"))
    
    print(theGraph)
    
  })
  
  
  output$topGraph <- renderPlot({
    
    top1 = filter(df, borough == input$borough & tree_dbh <= input$Treediameter & curb_loc ==input$Curb & month == input$months)
    top5 = filter(top1, spc_common %in% names(head(sort(table(top1$spc_common), decreasing = TRUE), n=5)))
    barplot(head(sort(table(top1$spc_common), decreasing = TRUE)/dim(top1)[1]*100, n =5),
            main = "Top 5 species in Boroughs",
            xlab = "Species",
            col = "grey",
            las = 1,
            horiz = F 
    ) 
  })
  
  
  output$mapGraph <- renderPlot({
    
    new <- subset(df, borough== input$borough & curb_loc == input$Curb)
    coordinates(new) = c("longitude", "latitude")
    crs.geo1 = CRS("+proj=longlat")
    proj4string(new) = crs.geo1
    getwd()
    newyork<-readOGR(dsn = "/Users/birzhaniskakov/Desktop/untitled folder", layer="geo_export_9c3c5597-ff7e-4e42-ba66-cd4f465b9581")
    
    plot(newyork,main="Tree density in Boroughs") 
    
    points(new, pch=20, cex=0.1, col="orange")
    
  })
  
  output$textDisplay <- renderText({ 
    paste("<b>There were" , NROW(tree()), "trees in 5 boroughs analyzed from month", input$months,"<br>", "This Dashboard contains 4 graphs and 1 table.", "<br>","Status graph shows us the amount Alive, Dead and Stump trees in 5 boroughs.","<br>", "Health graph plots the tree health in each borough","<br>", "Top 5 species graph is a barplot and identifies the top 5 species in each borough.", "<br>" , "Tree Map shows the density of trees by locating each tree on the map.","<br>","Number of trees tab includes a table with the amount of trees filtered by status and borough.","<br>","<br>","You are selecting borough:",input$borough,"<br>","You are selecting Status option:",input$Stat[1],input$Stat[2],input$Stat[3],"<br>","You are selecting Health option:",input$healthGraph[1],input$healthGraph[2],input$healthGraph[3],"<br>","You are selecting Curb option:", input$Curb[1],input$Curb[2],"<b>")
  })
  
}

shinyApp (ui, server)
