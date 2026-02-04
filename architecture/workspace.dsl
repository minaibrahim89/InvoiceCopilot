workspace "Invoice Copilot" "A tool that extracts data from uploaded invoices using AI" {

    model {
        # Actors
        user = person "User" "An accountant who manages financial records and processes invoices."
        
        # Software System
        invoiceCopilot = softwareSystem "Invoice Copilot" "A tool that extracts data from uploaded invoices using AI." {
            webApp = container "Web Application" "A web application that allows users to upload invoices and view extracted data." {
                technology "React (frontend), ASP.NET Core (backend)"
                tags "WebApp"
            }
            database = container "Database" "Stores user data and extracted invoice information." {
                technology "Azure Database for PostgreSQL"
                tags "Database"
            }
            messageQueue = container "Message Queue" "Handles communication between the web application and background processing services." {
                technology "Azure Event Grid"
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
            aiDocumentService = container "AI Document Service" "Interacts with Azure AI Document Intelligence to extract data from invoices." {
                technology "Azure AI Document Intelligence"
                tags "AIDocumentService"
            }
            aiChatService = container "Chat Service" "Provides AI-powered chat functionality for user assistance." {
                technology "Azure OpenAI Service"
                tags "ChatService"
            }
            aiSearchService = container "AI Search Service" "Provides AI-powered search capabilities for invoice data." {
                technology "Azure AI Search"
                tags "AISearchService"
            }
            appMonitoring = container "Application Monitoring" "Monitors application performance and logs using Azure Application Insights." {
                technology "Azure Application Insights"
                tags "AppMonitoring"
            }
        }

        user -> webApp "Uses"
        webApp -> blobStorage "Uploads invoices to"
        webApp -> database "Reads from and writes to"
        webApp -> messageQueue "Sends invoice processing requests to"
        webApp -> aiChatService "Send user queries to"
        messageQueue -> processingFunction "Triggers"
        processingFunction -> blobStorage "Retrieves uploaded invoices from/writes processed data to"
        processingFunction -> aiDocumentService "Sends invoices to for data extraction"
        processingFunction -> database "Stores extracted data in"
        aiSearchService -> blobStorage "Indexes invoice data from"
        aiChatService -> aiSearchService "Queries"
        webApp -> appMonitoring "Sends application logs and performance data to"
        processingFunction -> appMonitoring "Sends function logs and performance data to"

        deploymentEnvironment "Production" {
            azure = deploymentNode "Microsoft Azure" "Cloud platform hosting the Invoice Copilot application." {
                resourceGroup = deploymentNode "InvoiceCopilot-RG" "Contains all resources for the Invoice Copilot application." {
                    deploymentNode "Azure App Service" "Hosts the Invoice Copilot web application." {
                        containerInstance webApp
                    }
                    deploymentNode "Azure Database for PostgreSQL" "Hosts the Invoice Copilot database." {
                        containerInstance database
                    }
                    deploymentNode "Azure Service Bus" "Hosts the Invoice Copilot message queue." {
                        containerInstance messageQueue
                    }
                    deploymentNode "Azure Functions" "Hosts the Invoice Copilot processing function." {
                        containerInstance processingFunction
                    }
                    deploymentNode "Azure Blob Storage" "Hosts the Invoice Copilot blob storage." {
                        containerInstance blobStorage
                    }
                }
            }            
        }
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