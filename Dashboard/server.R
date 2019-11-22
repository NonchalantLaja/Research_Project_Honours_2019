library(shiny)
library(shinydashboard)

# Defining the server logic required 
shinyServer(function(input, output) {
  
  # Plots
  output$volume <- renderPlot({
    
    with(data, plot(data$Date, data$TWTR.Volume, type = "b", main = "Volume Distribution of TWTR", xlab = "Date", ylab = "Volume"))
    })
  
  output$close <- renderPlot({
    
    with(data, plot(data$Date, data$TWTR.Adj.Close, type = "o", main = "Adj Close of TWTR", xlab = "Date", ylab = "Adj Close"))
    
  })
  
  output$close2 <- renderPlot({
    
    with(data, plot(data$Date, data$AMZN.Adj.Close, type = "s", main = "Adj Close of AMZN", xlab = "Date", ylab = "Adj Close"))
    
  })
  
  output$close3 <- renderPlot({
    
    with(data, plot(data$Date, data$GOOG.Adj.Close, type = "l", main = "Adj Close of GOOG", xlab = "Date", ylab = "Adj CLose"))
    
  })
  
  output$chosen <- renderValueBox({
    valueBox("Company Chosen ", input$choose_plot, icon = icon("eye") )
    
    })
  
  output$chosen_model <- renderValueBox({
    valueBox("Company Chosen ", input$choose_comp_model, icon = icon("eye") )
    
  })
  
  output$type1 <- renderPlot({
    
    with(data2, plot(data2[data2$Company == input$choose_plot,"Date"], data2[data2$Company == input$choose_plot,"Adj.Close"], type = "l", main = paste("Adj Close of ", input$choose_plot), xlab = "Date", ylab = "Adj Close"))
    
  })
  
  output$type2 <- renderPlot({
    
    with(data2, plot(data2[data2$Company == input$choose_plot,"Date"], data2[data2$Company == input$choose_plot,"Volume"], type = "b", main = paste("Volume of ", input$choose_plot), xlab = "Date", ylab = "Volume"))
    
  })
  
  output$type3 <- renderPlot({
    
    hist(data2[data2$Company == input$choose_plot,"Volume"], xlab = "Volume", main = paste("Volume Histogram of ", input$choose_plot))
    
  })
  
  
  output$company <- {(
    renderText(input$comp)
  )}
  
  #Summaries
  output$summary1 <- renderPrint({
    summary(data[,-1])
  })
  
  output$summary2 <- renderPrint({
    summary(data2[data2$Company == input$choose_comp_raw,])
  })
  
  output$new_feature <- DT::renderDataTable({
    
    d <- data2[data2$Company ==  input$choose_comp_model,]
    df_and_spread = gain_fall(d)
    
    new_data <- as.data.frame(df_and_spread[1])
    
    subset(new_data, select = -c(1, 2))
    
  })
  
  # Output the model running
  output$model_running <- renderPrint({
    d <- data2[data2$Company ==  input$choose_comp_model,]
    df_and_spread = gain_fall(d)
    
    
    withProgress(message = "Generating New Features",
                 detail = "This may take a while...", value = 0,{
                   for(i in 1:80){
                     incProgress(1/80)
                     Sys.sleep(0.25)
                   }
                 })
    df_and_spread[2]
  })
  
  output$goodness <- renderPrint({

  })
  
  output$distplot <- renderPlot({
  
  })
  
  output$model_acc <- renderPrint({
    # Print out the data spread
    d <- data2[data2$Company ==  input$choose_comp_model,]
    df_and_spread = gain_fall(d)
    
    withProgress(message = "Running Deep Model",
                 detail = "This may take a while...", value = 0,{
                   for(i in 1:80){
                     incProgress(1/80)
                     Sys.sleep(0.25)
                   }
                 })
    new_data <- as.data.frame(df_and_spread[1])
    eval_array <- model(new_data)
    eval_array2 <- model2(new_data)
    
    print("Deep Neural Net Module Accuracy %: ") 
    print(eval_array[[1]][2])

    
    print("MLP Neural Net Module Accuracy %: ")
    print(eval_array2[[1]][2])
    
    print("Logistic Regression Model Accuracy %:")
    
    print("10 Fold Cross Validation Accuracies for Deep NN:")
    print(eval_array[[2]])
    
    print("10 Fold Cross Validation Accuracies for MLP:") 
    print(eval_array2[[2]])

    print("10 Fold Cross Validation Accuracies for LR")
  })

  
  #Datatables
  output$company_all <- DT::renderDataTable({
    
    data[,-1]
    
  })
  
  output$company_data_table <- DT::renderDataTable({
    
    data2[data2$Company == input$choose_comp_raw, ]
  })

  
  # Download Handels
  output$download_data1 <- downloadHandler(
    filename = function(){
      paste("dataset_1", "csv", sep = ".")
    },
    
    content = function(file){
      write.csv(data[, -1], file)
    }
    
  )
  
  output$download_summary1 <- downloadHandler(
    filename = function(){
      paste("summary_1", "txt", sep = ".")
    },
    
    content = function(file){
      write.txt(summary(data[, -1]), file)
    }
  )
  
  output$download_data2 <- downloadHandler(
    filename = function(){
      paste("dataset_2", "csv", sep = ".")
    },
    
    content = function(file){
      write.csv(data2, file)
    }
    
  )
  
  output$download_summary2 <- downloadHandler(
    filename = function(){
      paste("summary_2", "txt", sep = ".")
    },
    
    content = function(file){
      write.txt(summary(data2), file)
    }
    
  )
  
  output$download_type1 <- downloadHandler(
    filename = function(){
      paste(paste("Adj-Close-of-", input$choose_plot), "png", sep = ".")
    },
    
    content = function(file){
      png(file)
      with(data2, plot(data2[data2$Company == input$choose_plot,"Date"], data2[data2$Company == input$choose_plot,"Adj.Close"], type = "l", main = paste("Adj Close of ", input$choose_plot), xlab = "Date", ylab = "Adj Close"))
      dev.off()
    }
    
  )
  
  output$download_type2  <- downloadHandler(
    filename = function(){
      paste(paste("Volume-of-", input$choose_plot), "png", sep = ".")
    },
    
    content = function(file){
      png(file)
      with(data2, plot(data2[data2$Company == input$choose_plot,"Date"], data2[data2$Company == input$choose_plot,"Volume"], type = "b", main = paste("Volume of ", input$choose_plot), xlab = "Date", ylab = "Volume"))
      dev.off()
    }
  )
  
  output$download_type3 <- downloadHandler(
    filename = function(){
      paste(paste("Volume-Histogram-of-", input$choose_plot), "png", sep = ".")
    },
    
    content = function(file){
      png(file)
      hist(data2[data2$Company == input$choose_plot,"Volume"], xlab = "Volume", main = paste("Volume Histogram of ", input$choose_plot))
      dev.off()
    }
    
  )
  
  
  # New Additions (Temp) Detailed Analysis

  
  
  
  
})
