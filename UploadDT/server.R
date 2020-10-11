
library(shiny)
library(dplyr)
library(ggplot2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  archivo_carga_1 <- reactive({
    if(is.null(input$upload_file_1)){
      return(NULL)
    }
    
    #browser()
    ext<-strsplit(input$upload_file_1$name, split = "[.]")[[1]][2]
    if(ext == 'csv'){
      file_data <-read.csv(input$upload_file_1$datapath)
      return(file_data)
    }
    if(ext == 'tsv'){
      file_data <-read.tsv(input$upload_file_1$datapath)
      return(file_data)
    }
    return(NULL)
    
  })
  
  output$contenido_archivo_1 <-renderTable(
    archivo_carga_1()
  )
  
  archivo_carga_2 <- reactive({
    if(is.null(input$upload_file_2)){
      return(NULL)
    }
    
    #browser()
    ext<-strsplit(input$upload_file_2$name, split = "[.]")[[1]][2]
    if(ext == 'csv'){
      file_data <-read.csv(input$upload_file_2$datapath)
      return(file_data)
    }
    if(ext == 'tsv'){
      file_data <-read.tsv(input$upload_file_2$datapath)
      return(file_data)
    }
    return(NULL)
    
  })
  
  output$contenido_archivo_2 <-DT::renderDataTable({
    archivo_carga_2() %>% DT::datatable(filter="top")
  })
  
  output$tabla1 <- DT::renderDataTable({
    diamonds %>% 
      datatable() %>%
      formatCurrency("price") %>%
      formatString(c("x","y","z"),suffix=" mm")
      
    
  })
  
  output$tabla2 <- DT::renderDataTable({
    mtcars %>% 
      datatable(options = list(pageLength=5,
                               lengthMenu=c(5,10,15)),
                filter = "top"
                )
    
  })
  
  output$tabla3 <- DT::renderDataTable({
    iris %>% 
      datatable(extensions = 'Buttons',
                options = list(dom='Bfrtip',
                               buttons=c('csv')),
                rownames = FALSE
      )
  })
  
  output$tabla4 <- DT::renderDataTable({
    mtcars %>% 
      datatable(selection = 'single')
  })
  
  output$tabla4_single_click <- renderText({
    input$tabla4_rows_selected
  })
  
  output$tabla5 <- DT::renderDataTable({
    mtcars %>% 
      datatable()
  })
  
  output$tabla5_multi_click <- renderText({
    input$tabla5_rows_selected
  })
  
  output$tabla6 <- DT::renderDataTable({
    mtcars %>% 
      datatable(selection = list(mode='single', target='column'))
  })
  
  output$tabla6_single_click <- renderText({
    input$tabla6_columns_selected
  })
  
  output$tabla7 <- DT::renderDataTable({
    mtcars %>% 
      datatable(selection = list(mode='multiple', target='column'))
  })
  
  output$tabla7_multi_click <- renderText({
    input$tabla7_columns_selected
  })
  
  output$tabla8 <- DT::renderDataTable({
    mtcars %>% 
      datatable(selection = list(mode='single', target='cell'))
  })
  
  output$tabla8_single_click <- renderPrint({
         input$tabla8_cells_selected 
  })
  
  output$tabla9 <- DT::renderDataTable({
    mtcars %>% 
      datatable(selection = list(mode='multiple', target='cell'))
  })
  
  output$tabla9_multi_click <- renderPrint({
    #if(!is.null(input$tabla8_rows_selected)){
    #  data_frame(row= input$tabla8_rows_selected,
    #             col=input$tabla8_columns_selected)
    #} else {NULL}
    input$tabla9_cells_selected
  })


})
