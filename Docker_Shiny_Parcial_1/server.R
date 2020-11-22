library(shiny)
library(pool)
library(RMySQL)
library(dplyr)
library(ggplot2)
library(plotly)
library(stringr)


#conexion a base de datos
connection <- function(){
    return(dbConnect(MySQL(),user='root', password='root123',
                     host='db',port=3306,dbname='academatica_db'))
}


conn <- connection()
#obtener data inicial
all_data = dbGetQuery(conn, "SELECT * FROM videos")
#obtener data filtrada inicial
data_filter <<- data.frame()
#cerrar conexion
dbDisconnect(conn)



# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    #filtrar por query
    getQuery <- function(query){
        conn = connection()
        queryData = dbGetQuery(conn,query)
        dbDisconnect(conn)
        return(queryData)
    }
    
    #contar total
    output$total <- renderInfoBox({
        infoBox(
            "Total de videos", paste0( nrow(all_data)),icon = icon("video"),
            color = "blue"
        )
    })
    
    #contar total de vistas
    output$total_views <- renderInfoBox({
        infoBox(
            "Total de vistas", sum(as.numeric(all_data$views), na.rm = TRUE),icon = icon("eye")
        )
        
    })
    
    #contar total de likes
    output$total_likes <- renderInfoBox({
        infoBox(
            "Total de likes", sum(as.numeric(all_data$likes), na.rm = TRUE),icon = icon("thumbs-up")
        )
    })
    
    #contar total dislikes
    output$total_dislikes <- renderInfoBox({
        infoBox(
            "Total de dislikes", sum(as.numeric(all_data$dislikes), na.rm = TRUE),icon = icon("thumbs-down"),
            color="red"
        )
    })
    
    #contar total comments
    output$total_comments <- renderInfoBox({
        infoBox(
            "Total de commentarios", sum(as.numeric(all_data$comments), na.rm = TRUE),icon = icon("comment"),
            color = "yellow"
        )
    })
    
    #renderizar opcion
    output$option <- renderText({
        input$option
    })
    
    #redireccionar a link de video top 10 seleccionado
    selectedCount <- eventReactive(input$count_table_rows_selected,{
        selectedrowindex <- as.numeric(input$count_table_rows_selected)
        data_f <- data_filter[selectedrowindex,]
        
        #browseURL(data_f['link'])
        output$frame_count <- renderText({
            return(as.character(data_f['iframe']))
        })
        
        str_replace_all(as.character(data_f['title']), "[[:punct:]]", " ")
        
    })
    
    #renderizar video seleccionado
    output$tab_count = renderText({
        selectedCount()
    })
 
    
    #grafica de barras segun opcion seleccionada
    output$count_data <- renderPlot({
        option = input$option
        query = paste("SELECT title,",option, ",video_id, iframe FROM videos", "ORDER BY",option,"DESC LIMIT 10")
        data_filter <<- getQuery(query)
        
        output$count_table <- DT::renderDataTable({
          DT::datatable(data_filter[1:3],
                        options = list(dom = 't'),
                        selection = "single")  
        })
        names(data_filter)[2] = "count"
        
        
         ggplot(data_filter,aes(title, count,text = title))+
            geom_bar(stat="identity",position = "dodge",aes(fill = title))+
             geom_text(aes(label=count), 
                       position = position_dodge(width = 1))+
            theme(axis.title.x=element_blank(),
                  axis.text.x=element_blank(),
                  axis.ticks.x=element_blank())
        
    })
    
    #renderizar likes
    output$plot <- renderPlot({
        plot(data$likes, type=input$plotType)
    })
    
    #renderizar vistas por anioo
    output$plot_data_year <- renderPlot({
        query = getQuery("SELECT YEAR(CONVERT(published_at, DATE)) AS YEAR, COUNT(*) 
                         AS TOTAL
                         FROM videos 
                         GROUP BY YEAR(CONVERT(published_at, DATE))")
        
        df = data.frame(query)
        df<-df[-which(is.na(df$YEAR)),]
        
        output$table_year <- renderTable(df)
        
        O <-ggplot(df, aes(x=YEAR,y=TOTAL)) +
            
            geom_line(size = 1, alpha = 0.75) +
            geom_point(size =3, alpha = 0.75) +
            
            ggtitle("VIDEOS PUBLICADOS POR ANIO") +
            geom_text(aes(label=TOTAL), 
                      position = position_dodge(width = 1))+
            labs(x="YEAR",y="COUNT")+
            scale_x_continuous(labels = c(df$YEAR),breaks = c(df$YEAR))
            theme_classic()
        O
    })
    
    #renderizar estadisticas por anioo
    output$plot_data_stats <- renderPlot({
        query = getQuery(paste("SELECT YEAR(CONVERT(published_at, DATE)) AS YEAR, SUM(",input$option_stats,")
                         AS TOTAL
                         FROM videos 
                         GROUP BY YEAR(CONVERT(published_at, DATE))"))
        
        df = data.frame(query)
        df<-df[-which(is.na(df$YEAR)),]
        
        output$table_stats <- renderTable(df)
        
        O <-ggplot(df, aes(x=YEAR,y=TOTAL)) +
            
            geom_line(size = 1, alpha = 0.75) +
            geom_point(size =3, alpha = 0.75) +
            
            ggtitle(paste(toupper(input$option_stats)," POR ANIO")) +
            labs(x="YEAR",y=toupper(input$option_stats))+
            scale_x_continuous(labels = c(df$YEAR),breaks = c(df$YEAR))
        theme_classic()
        O
    })
    
    #renderizar video seleccionado
    output$tab_count = renderText({
        selectedCount()
    })
    
    #renderizar summary de tabla
    output$summary <- renderPrint({
        summary(all_data)
    })
    
    #renderizar total de registros de data inicial
    output$table <- DT::renderDataTable({
        DT::datatable(all_data, rownames=FALSE,
                      extensions = list(Scroller=NULL,  FixedColumns=list(leftColumns=2)),
                      selection = "single",
                      options = list(
                          dom = 'T<"clear">lfrtip',
                          autoWidth = TRUE,
                          columnDefs = list(list(width = '100%', targets = list(1:14))),
                          deferRender=TRUE,
                          scrollX=TRUE,scrollY=400,
                          scrollCollapse=TRUE,
                          pageLength = 10, lengthMenu = c(10,50,100,200)
                          
                      ))
    })
    
    #evento para seleccionar de tabla principal
    selectedRow <- eventReactive(input$table_rows_selected,{
        selectedrowindex <- as.numeric(input$table_rows_selected)
        data_f <- all_data[selectedrowindex,]
        text <- ""
        
        url <- a("ir a video", href=data_f['link'])
        output$tab <- renderUI({
            tagList("URL link:", url)
        })
        
        for (r in names(data_f)) {
			text = paste(text,r,':',str_replace_all(as.character(data_f[r]), "[[:punct:]]", " "),"\n")
        }
        
        output$frame <- renderText({
            return(as.character(data_f['iframe']))
        })
        #print(names(data_f))
        text
    })
    
    #mostrar informacion de fila seleccionada
    output$table_content_click = renderText({
        selectedRow()
    })
    

})
