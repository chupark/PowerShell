## https://stackoverflow.com/questions/31409009/how-to-have-a-powershell-function-return-a-table
Function MakeTable ($TableName, $ColumnArray)
{
$btab = New-Object System.Data.DataTable("$TableName")
foreach($Col in $ColumnArray)
  {
    $MCol = New-Object System.Data.DataColumn $Col;
    $btab.Columns.Add($MCol)

  }
return , $btab
}

$acol = @("bob","wob","trop")
$atab = MakeTable "Test" $acol

$aRow = $atab.NewRow()
$aRow["bob"] = "t1"
$aRow["wob"] = "t2"
$aRow["trop"] = "t3"
$atab.Rows.Add($aRow)
$atab 