workspace "Invoice Copilot" "A tool that extracts data from uploaded invoices using AI" {

    !identifiers hierarchical

    model {
        # Actors
        user = person "User" "An accountant who manages financial records and processes invoices."
        
        # External Systems
        azureSqlDatabase = softwareSystem "Azure SQL Database" "A fully managed relational database service provided by Microsoft Azure."
        azureServiceBus = softwareSystem "Azure Service Bus" "A fully managed enterprise message broker with message queues and publish-subscribe topics."
        azureFunctions = softwareSystem "Azure Functions" "Serverless compute service provided by Microsoft Azure."
        azureBlobStorage = softwareSystem "Azure Blob Storage" "Object storage solution for the cloud."
        azureDocumentIntelligence = softwareSystem "Azure AI Document Intelligence" "AI service for extracting structured data from documents."
        azureAISearch = softwareSystem "Azure AI Search" "AI-powered search service for building search applications."
        azureOpenAI = softwareSystem "Azure OpenAI" "Service that provides access to OpenAI's powerful language models."
        azureApplicationInsights = softwareSystem "Azure Application Insights" "Application performance management service for monitoring live applications."

        invoiceCopilot = softwareSystem "Invoice Copilot" "A tool that extracts data from uploaded invoices using AI." {
            wa = container "Web Application" "A web application that allows users to upload invoices and view extracted data." {
                technology "React (frontend), ASP.NET Core (backend)"
                tags "WebApp"
            }
            db = container "Database" "Stores user data and extracted invoice information." {
                technology "Azure SQL Database"
                tags "Database"
            }
            messageQueue = container "Message Queue" "Handles communication between the web application and background processing services." {
                technology "Azure Service Bus"
                tags "MessageQueue"
            }
            processingFunction = container "Processing Function" "Background service that processes uploaded invoices using AI services." {
                technology "Azure Functions"
                tags "Function"
            }
            blobStorage = container "Blob Storage" "Stores the uploaded invoice files." {
                technology "Azure Blob Storage"
                tags "BlobStorage"
            }
        }

        # u -> ss.wa "Uses"
        # ss.wa -> ss.db "Reads from and writes to"
    }

    # views {
    #     systemContext ss "Diagram1" {
    #         include *
    #     }

    #     container ss "Diagram2" {
    #         include *
    #     }

    #     styles {
    #         element "Element" {
    #             color #55aa55
    #             stroke #55aa55
    #             strokeWidth 7
    #             shape roundedbox
    #         }
    #         element "Person" {
    #             shape person
    #         }
    #         element "Database" {
    #             shape cylinder
    #         }
    #         element "Boundary" {
    #             strokeWidth 5
    #         }
    #         relationship "Relationship" {
    #             thickness 4
    #         }
    #     }
    # }

    # configuration {
    #     scope softwaresystem
    # }

}