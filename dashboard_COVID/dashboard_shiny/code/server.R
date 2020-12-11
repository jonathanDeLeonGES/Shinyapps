#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(RMySQL)
library(shiny)
library(leaflet)
library(shinydashboard)
library(RColorBrewer)
library(tidyverse)
library(ggplot2)
library(plotly)
library(lubridate)
library(shinyWidgets)


confirmados <- read.csv(file = 'data/confirmed.csv', sep = ",")
confirmados$variable <- format(as.Date(confirmados$variable,format = "%m/%d/%y"),"20%y/%m/%d")
confirmados$variable <- as.Date(confirmados$variable)

muertos <- read.csv(file = 'data/deaths.csv', sep = ",")
muertos$variable <- format(as.Date(muertos$variable,format = "%m/%d/%y"),"20%y/%m/%d")
muertos$variable <- as.Date(muertos$variable)

recuperados <- read.csv(file = 'data/recovered.csv', sep = ",")
recuperados$variable <- format(as.Date(recuperados$variable,format = "%m/%d/%y"),"20%y/%m/%d")
recuperados$variable <- as.Date(recuperados$variable)

server <- function(input, output, session) {
    
    # --------------------------------------------------------------------------------------
    
    # Render de Tabla Datos Confirmados
    output$TablaConfirmados <- renderDataTable({
        filteredDataConfirmados()
    })
    
    # Filtro de Datos de Tabla Confirmados
    filteredDataConfirmados <- reactive({

        if (input$PaisConfirmados == "TODOS"){
            confirmados[confirmados$value >= input$n_confirmados[1] & confirmados$value <= input$n_confirmados[2] &
                        confirmados$variable >= input$`ConfDate-Input`[1] & confirmados$variable <= input$`ConfDate-Input`[2]   ,]
        }else if (input$PaisConfirmados == "NINGUNO" ){
            confirmados[confirmados$value > input$n_confirmados[1] & confirmados$value < input$n_confirmados[1] ,]   
        }else{
            confirmados[confirmados$value >= input$n_confirmados[1] & confirmados$value <= input$n_confirmados[2] &
                            confirmados$Country.Region == input$PaisConfirmados &
                            confirmados$variable >= input$`ConfDate-Input`[1] & confirmados$variable <= input$`ConfDate-Input`[2],]    
        }
    })
    
    # Mapa de Datos Confirmados
    output$mapa_confirmados <- renderLeaflet({
        leaflet(confirmados) %>% addTiles() %>% setView(lng = 12.56738, lat = 41.87194, zoom = 04) 
    })
    
    # Actualizacion del Mapa con Puntos y Datos Filtrados
    observe({
        
        pal_confirmados <- colorFactor(
            palette = 'Spectral',
            domain = confirmados$value
        )
        
        leafletProxy("mapa_confirmados", data = filteredDataConfirmados()) %>%
            clearShapes() %>%
            addCircles(radius = ~log(value)*8000, weight = 1, color = "#777777",
                       fillColor = ~pal_confirmados(value), fillOpacity = 0.1, popup = ~paste(value)
            ) %>%
            clearControls() %>%
            addLegend(position = "bottomright",
                      pal = colorNumeric('Spectral', confirmados$value), values = ~confirmados$value
            )
        
    })
    
    # --------------------------------------------------------------------------------------
    
    # Render de Tabla Datos Muertos
    output$TablaMuertos <- renderDataTable({
        filteredDataMuertos()
    })
    
    # Filtro de Datos de Tabla Muertos
    filteredDataMuertos <- reactive({
        
        if (input$PaisMuertos == "TODOS"){
            muertos[muertos$value >= input$n_muertos[1] & muertos$value <= input$n_muertos[2] &
                        muertos$variable >= input$`muertosDate-Input`[1] & muertos$variable <= input$`muertosDate-Input`[2]   ,]
        }else if (input$PaisMuertos == "NINGUNO" ){
            muertos[muertos$value > input$n_muertos[1] & muertos$value < input$n_muertos[1] ,]   
        }else{
            muertos[muertos$value >= input$n_muertos[1] & muertos$value <= input$n_muertos[2] &
                        muertos$Country.Region == input$PaisMuertos &
                        muertos$variable >= input$`muertosDate-Input`[1] & muertos$variable <= input$`muertosDate-Input`[2],]    
        }
    })
    
    # Mapa de Datos Muertos
    output$mapa_muertos <- renderLeaflet({
        leaflet(muertos) %>% addTiles() %>% setView(lng = 12.56738, lat = 41.87194, zoom = 04) 
    })
    
    # Actualizacion del Mapa con Puntos y Datos Filtrados
    observe({
        
        pal <- colorFactor(
            palette = 'Spectral',
            domain = muertos$value
        )
        
        leafletProxy("mapa_muertos", data = filteredDataMuertos()) %>%
            clearShapes() %>%
            addCircles(radius = ~log(value)*8000, weight = 1, color = "#777777",
                       fillColor = ~pal(value), fillOpacity = 0.1, popup = ~paste(value)
            ) %>%
            clearControls() %>%
            addLegend(position = "bottomright",
                      pal = colorNumeric('Spectral', muertos$value), values = ~muertos$value
            )
    })
    # --------------------------------------------------------------------------------------
    
}
