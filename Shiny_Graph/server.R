library(shiny)
library(DT)

#Datos que necesitamos que se inicialicen una vez
data_event_click<-NULL
data_event_brush<-NULL
data_event_hover<-NULL
data<-NULL

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$dt_table <- DT::renderDataTable({
        
        mtcars_df <- cbind(carname=row.names(mtcars),mtcars)
        
        #Si fue un click
        if(!is.null(input$clk$x)){
            data <- nearPoints(mtcars_df, input$clk, xvar='wt', yvar='mpg')
            #data <<- rbind(data,dt) %>% dplyr::distinct()
        } 
        
        #si fue un brush
        if (!is.null(input$mbrush$xmin)) {
            data<- brushedPoints(mtcars_df, input$mbrush, xvar='wt',yvar='mpg')
        }
        
        #Si esta nulo, se carga el dataset completo
        if(is.null(data)){
            data<-mtcars_df 
        } else {
            data
        }
        
    })
    
    #Metodo para almacenar los puntos dependiendo la acción
    puntos_pintar <- reactive({ 
        if(!is.null(input$mbrush)){
            df<-brushedPoints(mtcars,input$mbrush,xvar='wt',yvar='mpg')
            out <- df %>% 
                select(wt,mpg)
            data_event_brush <<- rbind(data_event_brush,out) %>% dplyr::distinct()
            data_event_click <<- setdiff(data_event_click,out)
            data_event_hover <<- setdiff(data_event_hover,out)
        }
        
        if(!is.null(input$clk$x)){
            df<-nearPoints(mtcars,input$clk,xvar='wt',yvar='mpg')
            out <- df %>% 
                select(wt,mpg)
            data_event_click <<- rbind(data_event_click,out) %>% dplyr::distinct()
            data_event_brush <<- setdiff(data_event_brush,out)
            data_event_hover <<- setdiff(data_event_hover,out)
        }
        
        if(!is.null(input$mhover$x)){
            df<-nearPoints(mtcars,input$mhover,xvar='wt',yvar='mpg')
            out <- df %>% 
                select(wt,mpg)
            data_event_hover <<- rbind(data_event_hover,out) %>% dplyr::distinct()
            data_event_click <<- setdiff(data_event_click,out)
            data_event_brush <<- setdiff(data_event_brush,out)
        }
        
        if(!is.null(input$dclk$x)){
            df<-nearPoints(mtcars,input$dclk,xvar='wt',yvar='mpg')
            out <- df %>% 
                select(wt,mpg)
            data_event_click <<- setdiff(data_event_click,out)
            data_event_brush <<- setdiff(data_event_brush,out)
            data_event_hover <<- setdiff(data_event_hover,out)
            
        }
    })
    
    output$plot <- renderPlot({
        plot(mtcars$wt,mtcars$mpg,xlab = "Peso del Vehiculo", ylab="millas por galon")
        #Llamamos que determina los puntos a pintar
        puntos_pintar()
        
        if(!is.null(data_event_click)){
            points(data_event_click[,1],data_event_click[,2],
                   col='green',
                   pch=16,
                   cex=2)}
        
        if(!is.null(data_event_brush)){
            points(data_event_brush[,1],data_event_brush[,2],
                   col='blue',
                   pch=16,
                   cex=2)}
        
        if(!is.null(data_event_hover)){
            points(data_event_hover[,1],data_event_hover[,2],
                   col='gray',
                   pch=16,
                   cex=2)} 
        
    })
    
    
    
    
})
