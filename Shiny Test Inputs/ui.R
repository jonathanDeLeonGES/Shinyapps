#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(lubridate)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Inputs en Shiny"),
    
    #Panel de Tabs
    tabsetPanel(
        tabPanel("Inputs Examples",
                 sidebarLayout(
                     sidebarPanel(
                         sliderInput("Slider-input",
                                     "Number of bins:",
                                     value=50,
                                     min = 0,
                                     max = 100,
                                     step = 10,
                                     post= '%', animate = TRUE),
                         sliderInput("slider_input2",
                                     "Selecciona un rango",
                                     value = c(0,200),
                                     min = 0,
                                     max = 200,
                                     step = 10,
                                     animate=TRUE),
                         selectInput('select_input',
                                     "Seleccione un auto:",
                                     choices = row.names(mtcars),
                                     selected = "Camaro Z28",
                                     multiple = FALSE),
                         selectizeInput('select_input_2',
                                        "Seleccione autos;",
                                        choices = rownames(mtcars),
                                        selected = "Camaro Z28",
                                        multiple = TRUE),
                         dateInput('date_input',
                                   "Ingrese la fecha:",
                                   value= today(),
                                   weekstart=1,
                                   language='es'),
                         dateRangeInput("date_input2",
                                        "Ingrese Fechas",
                                        weekstart=1,
                                        language='es',
                                        separator = "to"),
                         numericInput("numeric_input",
                                      "Ingrese un número",
                                      value = 10
                                      ),
                         checkboxInput("checkbox_input",
                                       "Seleccione si verdadero"),
                         
                         checkboxGroupInput("checkbox_input2",
                                            "Seleccione opciones:",
                                            choices = c('A','B','C','D','E')),
                         radioButtons("radio_input",
                                      "Seleccione Genero",
                                      choices = c('masculino','femenino')),
                         textInput("text_input",
                                   "Ingrese Texto:"),
                         textAreaInput("paragraph_input",
                                       "Ingrese el Parrafo"),
                         actionButton("action_button","ok"),
                         actionLink("action_link","Siguiente"),
                         submitButton(text= "reprocesar")
                        ),
                     mainPanel(
                         h2("Slider input sencillo"),
                         verbatimTextOutput("slider-io"),
                         h2("Slider input rango"),
                         verbatimTextOutput("slider_io_2"),
                         h2("Select input"),
                         verbatimTextOutput("select_io"),
                         h2("Slider Input Multiple"),
                         verbatimTextOutput("Select_io_multi"),
                         h2("Fecha"),
                         verbatimTextOutput("date_io"),
                         h2("Rango de fechas"),
                         verbatimTextOutput("range_io"),
                         h2("Numeric Input"),
                         verbatimTextOutput("numeric_io"),
                         h2("single Checkbox"),
                         verbatimTextOutput("checkbox_io"),
                         h2("Grouped checkbox "),
                         verbatimTextOutput("group_checkbox_io"),
                         h2("Radio Buttons"),
                         verbatimTextOutput("radio_io"),
                         h2("Texto"),
                         verbatimTextOutput("text_io"),
                         h2("Parrafo"),
                         verbatimTextOutput("paragraph_io"),
                         h2("Action Button"),
                         verbatimTextOutput("button_io"),
                         h2("Action Link"),
                         verbatimTextOutput("link_io")
                     )
                 )
                 ),
        tabPanel("Cargar Archivo")
    )
))
