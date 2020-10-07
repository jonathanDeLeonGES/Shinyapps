#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$`slider-io` <- renderText({
        paste0(c('Output Slider input: ', input$`Slider-input`),collapse = '')
        
    })
    
    output$slider_io_2 <- renderText({
       input$slider_input2
    })

    output$select_io <- renderText({
        input$select_input
    })
    
    output$Select_io_multi <- renderText({
        paste0(c('Selecciones del UI: ', input$select_input_2),collapse = ' ')
    })
    
    output$date_io <- renderPrint({
        input$date_input
    })
    
    output$range_io <- renderPrint({
        input$date_input2
    })
    
    output$numeric_io <- renderText({
        input$numeric_input
    })
    
    output$checkbox_io <- renderText({
        input$checkbox_input
    })
    
    output$group_checkbox_io <- renderText({
        input$checkbox_input2
    })
    
    output$radio_io <- renderText({
        input$radio_input
    })
    
    output$text_io <- renderText({
        input$text_input
    })
    
    output$paragraph_io <- renderText({
        input$paragraph_input
    })
    
    output$button_io <- renderText({
        input$action_button
    })
    
    output$link_io <- renderText({
        input$action_link
    })
})
