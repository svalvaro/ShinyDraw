library(shiny)
library(reticulate)

ui <- fluidPage(
    h4("Click on plot to start drawing, click again to pause"),
    sliderInput("mywidth", "width of the pencil", min=1,
                max= 50, step=1, value=22),

    selectInput(inputId = 'model_select', 'Select a Neural Network',
                choices = c('Adam' = 'Adam', 'RMSprop' = 'rmsprop',
                            'Dropout' = 'dropout'),
                selected = 'Adam'
                ),
    actionButton("reset", "reset"),

    plotOutput("plot", width = "500px", height = "500px",
               hover=hoverOpts(id = "hover", delay = 100,
                               delayType = "throttle", clip = TRUE,
                               nullOutside = TRUE),
               click="click"),
    actionButton('predict', 'predict'),

    verbatimTextOutput("prediction"),

    br(),
    verbatimTextOutput('combined')
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

    number_plots <- reactiveValues(Plots = length(list.files('../ShinyDraw/www/pictures_to_predict/')))

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

        number_plots$Plots    <- length(list.files('../ShinyDraw/www/pictures_to_predict/'))



    })


    prediction <- reactive({

        input$predict


        if (number_plots$Plots == 0) {
            return(NULL)
        } else{

            #Select the neural network


            if (input$model_select == 'Adam') {
                python_output <- reticulate::py_run_file('../ShinyDraw/python_scripts/predictor.py')

            } else if(input$model_select == 'rmsprop'){

                python_output <- reticulate::py_run_file('../ShinyDraw/python_scripts/predictor_rmsprop.py', )
            } else if (input$model_select == 'dropout'){
                python_output <- reticulate::py_run_file('../ShinyDraw/python_scripts/predictor_dropout.py', )
            }

            message(paste0('Predicted: ', python_output$result))

            return(list(python_output$result, python_output$confidence))

        }

    })


    output$prediction <- renderText({

        if(is.null(prediction())){

            message('no plots')

            return('There is nothing to predict.')

        } else {


            return(paste0('Predicted: ', prediction()[1], ' confidence: ',
                          format(round(as.numeric(prediction()[2])*100,1),nsmall = 1),
                          ' %.'))

        }
    })




    # Combine multiple positive prediction, don't store when reset is pressed.



    combined <- reactive({

        #string <- cat(prediction())

        return(string)
    })




    output$combined <- renderText(combined())

    # Remove plots after finishings.

    session$onSessionEnded(function() {
        cat("Session Ended\n")
        unlink('../ShinyDraw/www/pictures_to_predict/plotw.png')
    })


}


shinyApp(ui, server)
