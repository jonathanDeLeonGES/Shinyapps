library(shiny)
library(dplyr)

out_click<- NULL
out_hover<-NULL

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Titulo de Aplicación
    titlePanel("Laboratorio 2 - Shiny Apps"),
    
    #TabsetPanel para Tarea
    tabsetPanel(
        tabPanel("Grafica Tarea",
                 plotOutput("plot",
                            click= 'clk',
                            dblclick = "dclk",
                            hover= "mhover",
                            brus = "mbrush"),
                 DT::dataTableOutput('dt_table')
                )
    )
))
