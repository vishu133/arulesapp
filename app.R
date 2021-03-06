#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
EnsurePackage <- function(x) {
  x <- as.character(x)
  if( !require(x,character.only = T))
  {install.packages(x,repos = "https://cran.r-project.org/")
    require(x,character.only = T)}
}
library(shiny)
library("arules")
library("arulesViz")
library("shiny")
library("caret")
library("colorspace")
data("AdultUCI")

#Data Preprocessing: For ARules by converting integers to categories

AdultUCI$age_grp <- discretize(AdultUCI$age, method = "cluster",
                               labels = c("Young","Middle Aged","Senior"),
                               order = T,onlycuts = F)

AdultUCI$hours_per_week_grp <- discretize(AdultUCI$`hours-per-week`,method = "fixed",
                                          categories = c(-Inf,25,41,60,Inf),
                                          labels = c("Part-time","Full-time",
                                                     "Over-time","Burn-out 60"),
                                          order = T)
AdultUCI$capital_gain_grp <- discretize(AdultUCI$`capital-gain`,method = "fixed",
                                        categories = c(-Inf,0,1,10000,99998,Inf),
                                        labels = c("None","Low",
                                                   "High","Super High"),
                                        order = T)
AdultUCI$capital_loss_grp <- discretize(AdultUCI$`capital-loss`,method = "fixed",
                                        categories = c(-Inf,0,1,1000,2000,Inf),
                                        labels = c("None","Low","Med",
                                                   "High"),
                                        order = T)


# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Arules"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         numericInput("supp",
                     "Min Support:",
                     value = 0.1),
         numericInput("conf",
                      "Confidence",
                      value = 0.5),
         numericInput("minlen",
                      "Minimum Rules",
                      value = 3),
         numericInput("maxlen",
                      "Max Rules",
                      value = 10),
         actionButton("button", "Find Rules"))
      ,
      
      # Show a plot of the generated distribution
      mainPanel(
         verbatimTextOutput("Arules")
      )
   ))

# Define server logic required to draw a histogram
server <- function(input, output) {
   
amodel <- eventReactive(input$button,{
      rules_record1 <- apriori(AdultUCI[,sapply(AdultUCI, is.factor)],
                               parameter = list(support = input$supp, 
                                                confidence = input$conf,
                                                minlen = input$minlen,
                                                maxlen = input$maxlen))
      return(inspect(sort(rules_record1, by = "lift",decreasing = T)[1:10]))})
   
output$Arules <- renderPrint(amodel())
}

# Run the application 
shinyApp(ui = ui, server = server)

