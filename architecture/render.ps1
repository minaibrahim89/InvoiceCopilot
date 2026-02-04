$PATH = Split-Path -Parent $MyInvocation.MyCommand.Path
docker run -d --rm --name invoice-copilot-structurizr -p 8080:8080 -v "${PATH}:/usr/local/structurizr" structurizr/lite
Sleep 10
Start-Process "http://localhost:8080"
