# =====================================================
# PROJET AERIEN – SHINY WEB APP
# MISSION 3 : ANALYSES & VISUALISATION
# (ADAPTÉ À LA BDD RÉELLE : SANS flights)
# =====================================================

library(shiny)
library(DBI)
library(RMySQL)
library(ggplot2)
library(dplyr)

# =====================================================
# CONNEXION A LA BASE MYSQL
# =====================================================

con <- dbConnect(
  RMySQL::MySQL(),
  dbname = "aerien",
  host = "localhost",
  user = "root",
  password = ""
)

# =====================================================
# INTERFACE UTILISATEUR (UI)
# =====================================================

ui <- fluidPage(
  
  titlePanel("✈️ Dashboard Trafic Aérien – Données Météo"),
  
  tabsetPanel(
    
    tabPanel(
      "📊 Observations météo par aéroport",
      plotOutput("plot_obs")
    ),
    
    tabPanel(
      "🌡️ Température moyenne par aéroport",
      plotOutput("plot_temp")
    ),
    
    tabPanel(
      "🌬️ Vent moyen par aéroport",
      plotOutput("plot_wind")
    ),
    
    tabPanel(
      "📋 Tableau récapitulatif météo",
      tableOutput("table_summary")
    )
  )
)

# =====================================================
# LOGIQUE SERVEUR
# =====================================================

server <- function(input, output) {
  
  # ---- Nombre d'observations météo par aéroport ----
  output$plot_obs <- renderPlot({
    
    df <- dbGetQuery(con, "
  SELECT `COL 1` AS origin, COUNT(*) AS nb_observations
  FROM weather
  GROUP BY `COL 1`
  ORDER BY nb_observations DESC
")

    
    ggplot(df, aes(x = reorder(origin, nb_observations), y = nb_observations)) +
      geom_col(fill = 'steelblue') +
      coord_flip() +
      labs(
        title = 'Nombre d’observations météo par aéroport',
        x = 'Aéroport',
        y = 'Nombre d’observations'
      )
  })
  
  # ---- Température moyenne par aéroport ----
  output$plot_temp <- renderPlot({
    
    df <- dbGetQuery(con, "
      SELECT origin, AVG(temp) AS temp_moyenne
      FROM weather
      WHERE temp IS NOT NULL
      GROUP BY origin
    ")
    
    ggplot(df, aes(x = origin, y = temp_moyenne)) +
      geom_col(fill = 'darkgreen') +
      labs(
        title = 'Température moyenne par aéroport',
        x = 'Aéroport',
        y = 'Température moyenne (°F)'
      )
  })
  
  # ---- Vent moyen par aéroport ----
  output$plot_wind <- renderPlot({
    
    df <- dbGetQuery(con, "
      SELECT origin, AVG(wind_speed) AS vent_moyen
      FROM weather
      WHERE wind_speed IS NOT NULL
      GROUP BY origin
    ")
    
    ggplot(df, aes(x = origin, y = vent_moyen)) +
      geom_col(fill = 'orange') +
      labs(
        title = 'Vitesse moyenne du vent par aéroport',
        x = 'Aéroport',
        y = 'Vitesse du vent'
      )
  })
  
  # ---- Tableau récapitulatif météo ----
  output$table_summary <- renderTable({
    
    dbGetQuery(con, "
      SELECT origin,
             COUNT(*) AS nb_observations,
             ROUND(AVG(temp), 2) AS temp_moyenne,
             ROUND(AVG(wind_speed), 2) AS vent_moyen,
             ROUND(AVG(precip), 2) AS precip_moyenne
      FROM weather
      GROUP BY origin
      ORDER BY nb_observations DESC
    ")
  })
}

# =====================================================
# LANCEMENT DE L'APPLICATION
# =====================================================

shinyApp(ui = ui, server = server)
