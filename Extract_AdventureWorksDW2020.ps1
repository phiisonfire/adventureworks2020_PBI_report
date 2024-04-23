# SQL Server Connection String
$serverName = "DESKTOP"
$databaseName = "AdventureWorksDW2020"
$userId = "phinguyen"
$password = "1"

# Create a connection string
$connectionString = "Server=$serverName;Database=$databaseName;User ID=$userId;Password=$password;"

# Create a connection
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

# Open the connection
$connection.Open()

# Read the .sql file
$sqlQueries = (Get-Content -Path "C:\Users\TGC\Desktop\Power BI\AdventureWorksDW2020_Extract.sql" -Raw) -split ';'

# Specify the excel path
$excelPath = "C:\Users\TGC\Desktop\Power BI\AdventureWords_Extracted.xlsx"

foreach ($query in $sqlQueries) {
    if (-not [string]::IsNullOrWhiteSpace($query)) {
        $firstline = $query.Trim() -split "`r?`n" | Select-Object -First 1
        $sheetname = $firstline.Substring(2)

        $command = $connection.CreateCommand()
        $command.CommandText = $query
        $result = $command.ExecuteReader()

        # Load the result into a DataTable
        $dataTable = New-Object System.Data.DataTable
        $dataTable.Load($result)

        # Export the result to Excel
        $dataTable | Export-Excel -Path $excelPath -WorksheetName $sheetname

        $result.Close()
    }
}


$connection.Close()
