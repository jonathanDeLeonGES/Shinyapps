#
# Parcial - Parte 2 - Product Development - Desarrollo Dashboard Shiny
# Server.R

library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
library(plotly)
library(tidyverse)

##------------------------------------------
##Funciones para transformar y filtrar datos
##------------------------------------------
## formatear fechas
formatDate = function(date){
    return(as.Date(date, '%m/%d/%Y'))
}


##filtrar data por rango de fechas
filterByDate = function(df,from="", to=""){
    filter_data = df
    filter_data = df %>% 
        mutate(ORDERDATE = formatDate(ORDERDATE)) %>%
        filter(ORDERDATE >= from, ORDERDATE<= to)
    return(filter_data)
}

##filter por columna
filterByCountry = function(df,col,items){
    filter_data = df %>% 
        filter(!!as.name(col) %in% items)
    return(filter_data)
}
##------------------------------------------

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    #-------------------------------------------------
    #Carga del Dataset que se usará para el Dashboard
    #-------------------------------------------------
    load_dataset<- function(){
        location<- 'sales.csv'
        file_data<- read.csv(location)
        return(file_data)
    }
    
    dataset_sales<-load_dataset()
    #Se deja una columna del DataSet con la fecha de la orden de compra, incluyendo Hora y Timezone.
    dataset_sales$ORDERDATE_TZ<-as.POSIXct(dataset_sales$ORDERDATE,format="%m/%d/%Y %H:%M",tz=Sys.timezone())
    #Se transforma la columana de Fecha de Orden
    dataset_sales <- dataset_sales %>% 
                        mutate(ORDERDATE = formatDate(ORDERDATE))
    #-------------------------------------------------
    
    #--------------------------------------------------------------
    #setear data default - Para los controles
    #--------------------------------------------------------------
    setDefaultDates= function(df){
        bins<-30
        init_date = min(df$ORDERDATE)
        end_date = max(df$ORDERDATE)
        countries = unique(df$COUNTRY)
        products = unique(df$PRODUCTLINE)
        status = unique(df$STATUS)
        customers = unique(df$CUSTOMERNAME)
        updateDateRangeInput(session, "date_filter",
                             start = init_date,
                             end = end_date,
                             min = init_date,
                             max = end_date
        )
        
        updateSliderInput(session, "bins",value =bins )
        
        updatePickerInput(session, "country",
                          choices = countries,
                          selected = countries)
        
        updatePickerInput(session, "product",
                          choices = products,
                          selected = products)
        
        updatePickerInput(session, "status",
                          choices = status,
                          selected = status)
        
        updatePickerInput(session, "customer",
                          choices = customers,
                          selected = customers)
        
        updatePickerInput(session, "country_city",
                          choices = countries,
                          selected = countries[1])
    }
    
    #inicializar informacion valores default
    setDefaultDates(dataset_sales)
    
    
    #-------------------------------------------------
    #Carga de Parametros que vienen desde la URL
    #-------------------------------------------------
    observe({
        query<-parseQueryString(session$clientData$url_search)
        bins<-query[["bins"]]
        dateMin<-query[["dateMin"]]
        dateMax<-query[["dateMax"]]
        countries<-query[["Countries"]]
        products<-query[["Products"]]
        status<-query[["Estado"]]
        if(!is.null(bins)){
            bins <-as.integer(bins)
            updateSliderInput(session,"bins",value = bins)
        }
        if(!is.null(dateMin)){
            dateMin<-as.Date(dateMin)
            updateDateRangeInput(session,"date_filter",start = dateMin)
        }
        if(!is.null(dateMax)){
            dateMax<-as.Date(dateMax)
            updateDateRangeInput(session,"date_filter",end = dateMax)
        }
        if(!is.null(countries)){
            countries<-unlist(strsplit(countries, ","))
            updateCheckboxGroupInput(session,"country",selected = countries)
        }
        if(!is.null(products)){
            products<-unlist(strsplit(products, ","))
            updateCheckboxGroupInput(session,"product",selected = products)
        }
        if(!is.null(status)){
            status<-unlist(strsplit(status, ","))
            updateCheckboxGroupInput(session,"status",selected = status)
        }
        
        
    })
    #-------------------------------------------------
    
    #Carga de Tabla - DataTable 
    output$contenido_dataset <- DT::renderDataTable({
        
        dataset_sales %>%  
            DT::datatable(filter="top",selection = 'single', options=list(scrollX=TRUE)) %>%
            formatCurrency("PRICEEACH") %>%
            formatCurrency("SALES")
    })
    
    #Evento Reactive - Que aplicará los filtros en el Dataset
    changefilters<-reactive({
        
        from = input$date_filter[1]
        to = input$date_filter[2]
        filter_values = filterByDate(dataset_sales,from,to)
        
        #filter por pais
        countries = input$country
        filter_values = filterByCountry(filter_values,"COUNTRY",countries)
        
        #filter por producto
        products = input$product
        filter_values = filterByCountry(filter_values,"PRODUCTLINE",products)
        
        #filter por status
        status = input$status
        filter_values = filterByCountry(filter_values,"STATUS",status)
        
        #filter por cliente
        clientes = input$customer
        filter_values = filterByCountry(filter_values,"CUSTOMERNAME",clientes)
        
        #Actualizamos el Filtro por Pais
        updatePickerInput(session, "country_city",
                          choices = countries,
                          selected = countries[1])
        
        return(filter_values)
    })
    
    ##resetar informacion
    observeEvent(input$reset,{
        setDefaultDates(dataset_sales)
    })
    
    output$distPlot <- renderPlot({
        dataset_sales_filter<-changefilters()
        # genera el número de bloques de acuerdo a input$bins from ui.R
        if(nrow(dataset_sales_filter)>0){
            orders    <- dataset_sales_filter[, 2]
            bins <- seq(min(orders), max(orders), length.out = input$bins + 1)
            
            # Dibuja el Histograma de Ordenes de acuerdo al número de bloques
            return(hist(orders, 
                     breaks = bins, 
                     col = 'deepskyblue', 
                     border = 'white',
                     main = paste("Histograma de Cantidad de Productos en Ordenes")))
        }
        return(NULL)
    })
    
    output$SalesBydate<-renderPlot({
        
        dataset_sales_filter<-changefilters()
        
        if(nrow(dataset_sales_filter)>0){
        return(dataset_sales_filter%>%
                ggplot(aes(ORDERDATE_TZ,color = "gold1")) + 
                geom_freqpoly(binwidth = 86400)+ # 86400 segundos = 1 dia
                ggtitle("Cantidad de Ordenes por día")+
                xlab("Fecha")+
                ylab("Cantidad")+
                scale_color_manual(values = "gold1")+
                theme(plot.title = element_text(size=rel(1.4),face="bold",hjust = 0.5),
                      panel.background = element_rect(fill = NA),
                      legend.position = "none"))
        }
        return(NULL)
    })
    
    output$ordersbyCountry<-renderPlot({
        
        dataset_sales_filter<-changefilters()
        
        if(nrow(dataset_sales_filter)>0){
            return(dataset_sales_filter %>%
                    ggplot(aes(x=COUNTRY, fill=COUNTRY))+ 
                    geom_bar()+ coord_polar()+
                    ggtitle("Cantidad de Ordenes por Pais")+
                    ylab("Conteo")+
                    theme(plot.title = element_text(size=rel(1.4),face="bold",hjust = 0.5),
                          axis.title.x=element_blank(), axis.text.x=element_blank(), axis.ticks.x=element_blank()))
        }
        return(NULL)
    })
    
    output$link_io<-renderText({
        bins<-input$bins
        dateMin<-input$date_filter[1]
        dateMax<-input$date_filter[2]
        countries<-paste(input$country,collapse=",")
        products<-paste(input$product,collapse=",")
        status<-paste(input$status,collapse=",")
        paste0(session$clientData$url_protocol,"//",
                         session$clientData$url_hostname,':',
                         session$clientData$url_port,
                         session$clientData$url_pathname,
                         "?bins=",bins,"&",
                         "dateMin=",dateMin,"&",
                         "dateMax=",dateMax,"&",
                         "Countries=",countries, "&",
                         "Products=",products,"&",
                         "Estado=",status)
    })
    
    output$orders <- renderValueBox({
        df<-changefilters()
        
        value = nrow(df)
        valueBox(
            value, "Ordenes", icon = icon("credit-card"),
            color = "blue"
        )
    })
    
    #contar ordenes enviadas
    output$shipped <- renderValueBox({
        df<-changefilters()
        
        values = df %>%
            filter(STATUS == 'Shipped')
        value = nrow(values)
        valueBox(
            value, "Ordenes enviadas", icon = icon("paper-plane"),
            color = "green"
        )
    })
    
    #contar total de ventas
    output$sales <- renderValueBox({
        df<-changefilters()
        
        value = sum(df$SALES)
        valueBox(
            paste0('$./',value), "Total en ventas", icon = icon("dolar"),
            color = "yellow"
        )
    })
    
    #renderizar y grafica de status
    output$orders_status_tbl = renderTable({
        df<-changefilters()
        status_data = df %>% group_by(STATUS) %>% tally()
        status_data['per'] = (status_data['n']/sum(status_data$n)) * 100
        
        #grafica
        if(nrow(df)>0){
            output$status_chart = renderPlot({
                mycols <- c("#CD534CFF","#868686FF","#EFC899FF","#0073C2FF", "#EFC000FF","#853606FF")
                count.data <- status_data %>%
                    arrange(desc(STATUS)) %>%
                    mutate(lab.ypos = cumsum(per) - 0.5*per)
                
                return(ggplot(count.data,aes(STATUS, n,text = STATUS))+
                    geom_bar(stat="identity",position = "dodge",aes(fill = STATUS))+
                    geom_text(aes(label=paste0(round(per,2),'%')), 
                              position = position_dodge(width = 1))+
                    theme(axis.title.x=element_blank(),
                          axis.text.x=element_blank(),
                          axis.ticks.x=element_blank()))
            
            })
        }
        
        #unique_status = unique(df$STATUS)
        return(status_data)
        
    })
    
    #Tabla de Ventas por Pais
    output$country_tbl<-renderTable({
        df<-changefilters()
        
        country_data = df %>%
            group_by(COUNTRY) %>%
            summarise(TOTAL = sum(SALES)) %>%
            ungroup() %>%
            mutate(label_text = str_glue("Pais: {COUNTRY}
                                       Ingresos: {scales::dollar(TOTAL)}"))
        country_data <- country_data[order(country_data$TOTAL,decreasing = TRUE),]
        
        #Grafica
        if(nrow(df)>0){
            output$country_chart  = renderPlotly({
                country_data %>%
                    
                    plot_geo(locationmode = "country names") %>%
                    
                    add_trace(z = ~TOTAL,
                              locations = ~COUNTRY,
                              color = ~TOTAL,
                              text = ~label_text,
                              marker = list(line = list(
                                  color = toRGB("black"), width = 0.8)),
                              colors = "YlGnBu",
                              hoverinfo = "text") %>%
                    
                    colorbar(title = 'Ingreso',
                             tickprefix = '$',
                             x = 1, y = 0.8) %>% 
                    
                    return(layout(
                        showlegend = FALSE,
                        geo = list(
                            scope = "world",
                            bgcolor = toRGB("white", alpha = 0),
                            countrycolor = toRGB("gray"),
                            showcountries = TRUE,
                            showframe = FALSE,
                            showcoastlines = FALSE,
                            coastlinecolor = toRGB("#ECEFF1"),
                            projection = list(type = 'Equirectangular'))))
            })
        }
        
        
        return(head(country_data[1:2],5))
        
    })
    
    observeEvent(input$country_city, {
        df<-changefilters()
        country = input$country_city
        
        #group ciudades
        city_data = df %>%
            filter(COUNTRY == country)%>%
            group_by(CITY) %>%
            summarise(TOTAL = sum(SALES))
        
        city_data <- city_data[order(city_data$TOTAL,decreasing = TRUE),]
        output$country_city_tbl = renderTable(head(city_data,5))
        
        #city chart
        output$city_chart = renderPlotly({
            fig <- plot_ly() 
            fig %>%
                add_trace(
                    type = 'scatter',
                    mode = 'lines+markers',
                    x = city_data$CITY,
                    y = city_data$TOTAL,
                    text = city_data$TOTAL,
                    hovertemplate = paste('<b>SALES</b>: %{y:.2f}',
                                          '<br><b>CITY</b>: %{x}<br>'),
                    showlegend = FALSE
                )
        })
        
        #top productos mas consumidos por pais
        top_product_ordered = df %>%
            filter(COUNTRY == country)%>%
            group_by(PRODUCTLINE) %>%
            summarise(ORDERED = sum(QUANTITYORDERED), TOTAL = sum(SALES))
        
        #group anios
        year_data = df %>%
            filter(COUNTRY == country)%>%
            group_by(YEAR_ID) %>%
            summarise(TOTAL = sum(SALES))
        
        output$city_product_tbl = renderTable(top_product_ordered)
        output$country_city_chart = renderPlotly({
            fig <- plot_ly() 
            fig <- fig %>%
                add_trace(
                    type = 'scatter',
                    mode = 'lines+markers',
                    x = top_product_ordered$PRODUCTLINE,
                    y = top_product_ordered$ORDERED,
                    text = top_product_ordered$PRODUCTLINE,
                    hovertemplate = paste('<b>ORDERED</b>: %{y:.2f}',
                                          '<br><b>PRODUCT</b>: %{x}<br>'),
                    showlegend = FALSE
                ) 
            fig <- fig %>%
                add_trace(
                    type = 'scatter',
                    mode = 'lines+markers',
                    x = top_product_ordered$PRODUCTLINE,
                    y = top_product_ordered$TOTAL,
                    hovertemplate = paste('<b>SALES</b>: $%{y:.2f}',
                                          '<br><b>PRODUCT</b>: %{x}<br>'),
                    showlegend = FALSE
                )
            
            fig
        })
        
        #pie chart anios
        output$city_year_tbl = renderTable(year_data)
        output$country_year_chart = renderPlotly({
            fig <- plot_ly() 
            fig %>%
                add_trace(
                    type = "pie",
                    name = "",
                    values = year_data$TOTAL,
                    labels = year_data$YEAR_ID,
                    text = year_data$YEAR_ID,
                    hovertemplate = "%{label}: <br>SALES: %{percent} </br> %{text}")
        })
        
    })
    
})
