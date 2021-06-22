library(shiny)
library(reticulate)

ui <- fluidPage(
    h4("Click on plot to start drawing, click again to pause"),
    sliderInput("mywidth", "width of the pencil", min=1,
                max=30, step=1, value=22),
    actionButton("reset", "reset"),

    plotOutput("plot", width = "280px", height = "280px",
               hover=hoverOpts(id = "hover", delay = 100,
                               delayType = "throttle", clip = TRUE,
                               nullOutside = TRUE),
               click="click"),
    actionButton('predict', 'predict'),

    verbatimTextOutput("prediction")
    )



server <- function(input, output, session) {
    vals = reactiveValues(x=NULL, y=NULL)
    draw = reactiveVal(FALSE)
    observeEvent(input$click, handlerExpr = {
        temp <- draw(); draw(!temp)
        if(!draw()) {
            vals$x <- c(vals$x, NA)
            vals$y <- c(vals$y, NA)
        }})
    observeEvent(input$reset, handlerExpr = {
        vals$x <- NULL; vals$y <- NULL
    })
    observeEvent(input$hover, {
        if (draw()) {
            vals$x <- c(vals$x, input$hover$x)
            vals$y <- c(vals$y, input$hover$y)
        }})
    output$plot= renderPlot({
        plot(x=vals$x, y=vals$y,
             xlim=c(0, 28),
             ylim=c(0, 28),
             ylab="",
             xlab="",
             type="l",
             lwd=input$mywidth,
             axes=FALSE,
             frame.plot=TRUE)
    })


    observeEvent(input$predict, {

        outfile <- './www/pictures_to_predict/plotw.png'

        png(outfile, width = 280, height = 280)

        plot(x=vals$x, y=vals$y,
             xlim=c(0, 28),
             ylim=c(0, 28),
             ylab="",
             xlab="",
             type="l",
             lwd=input$mywidth,
             axes=FALSE,
             frame.plot=FALSE)
        dev.off()


        # Return a list containing the filename
        list(src = outfile,
             contentType = 'image/png',
             width = 28,
             height = 28)

    })



    output$prediction <- renderText({

        input$predict

        a <- reticulate::py_run_file('../ShinyDraw/python_scripts/predictor.py')

        if (is.null(a$result)) {
            return(NULL)
        }else{
            a$result
        }





    })

}


shinyApp(ui, server)
