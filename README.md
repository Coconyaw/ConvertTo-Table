# ConvertTo-Table
Powershell function that convert object array to text based table

## Usage

* `Get-Process | Select-Object CPU, Name | Sort-Object -Descending | ConvertTo-Table -TableFomat Markdown`
* `Get-ChildItem | Select-Object Name, Length, LastWriteTime | ConvertTo-Table -TableFomat Text`
* `Get-ChildItem | Select-Object Name, Length, LastWriteTime | ConvertTo-Table -TableFomat Text -PrintTable | Set-ClipBoard`

## Example

```
PS> Get-Process | Sort-Object -Property CPU -Descending | Select-Object CPU,Name -Fi rst 5 | ConvertTo-Table -TableFormat Text -PrintTable
+------------+----------+
| CPU        | Name     |
+------------+----------+
| 469.53125  | OUTLOOK  |
| 438.421875 | chrome   |
| 396.515625 | explorer |
| 321        | conhost  |
| 185.0625   | chrome   |
+------------+----------+

PS> Get-Process | Sort-Object -Property CPU -Descending | Select-Object CPU,Name -Fi rst 5 | ConvertTo-Table -TableFormat Markdown -PrintTable
| CPU | Name |
| --- | ---- |
| 470.203125 | OUTLOOK |
| 438.53125 | chrome |
| 397.875 | explorer |
| 325.296875 | conhost |
| 185.078125 | chrome |

PS> 
```
