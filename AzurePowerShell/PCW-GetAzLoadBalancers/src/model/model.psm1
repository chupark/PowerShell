## https://stackoverflow.com/questions/31409009/how-to-have-a-powershell-function-return-a-table

Function MakeTable ($TableName, $ColumnArray) {
    $table = New-Object System.Data.DataTable("$TableName")
    foreach($Col in $ColumnArray)
    {
        $MCol = New-Object System.Data.DataColumn $Col;
        $btab.Columns.Add($MCol)

      }
    return , $table
}