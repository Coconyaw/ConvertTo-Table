$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "ConvertTo-Table" {
	$TestCase = @(
		[PSCustomObject]@{A = 'a'; B = 'b'; C = 'c'},
		[PSCustomObject]@{A = 'aa'; B = 'bb'; C = 'cc'},
		[PSCustomObject]@{A = 'aaa'; B = 'bbb'; C = 'ccc'}
	)
	$ExpectedTable = [Table]::New()
	$ExpectedTable.Columns = 3
	$ExpectedTable.Rows = 3
	$ExpectedTable.TableText = "+-----+-----+-----+
| A   | B   | C   |
+-----+-----+-----+
| a   | b   | c   |
| aa  | bb  | cc  |
| aaa | bbb | ccc |
+-----+-----+-----+
"
    It "Text table format from argument" {
		$result = ConvertTo-Table -InputObject $TestCase -TableFormat Text
		# $result | Should BeOfType [Table]
		$result.Columns | Should Be $ExpectedTable.Columns
		$result.Rows | Should Be $ExpectedTable.Rows
		$result.TableText | Should Be $ExpectedTable.TableText
    }

    It "Text table format from pipeline" {
		$result = $TestCase | ConvertTo-Table -TableFormat Text
		# $result | Should BeOfType [Table]
		$result.Columns | Should Be $ExpectedTable.Columns
		$result.Rows | Should Be $ExpectedTable.Rows
		$result.TableText | Should Be $ExpectedTable.TableText
    }

    It "Text table with -PrintTable option" {
		$result = $TestCase | ConvertTo-Table -TableFormat Text -PrintTable
		$result | Should BeOfType [string]
		$result | Should Be $ExpectedTable.TableText
    }

	$ExpectedTable.TableText = "| A | B | C |
| - | - | - |
| a | b | c |
| aa | bb | cc |
| aaa | bbb | ccc |
"

    It "Markdown table format from argument" {
		$result = ConvertTo-Table -InputObject $TestCase -TableFormat Markdown
		# $result | Should BeOfType [Table]
		$result.Columns | Should Be $ExpectedTable.Columns
		$result.Rows | Should Be $ExpectedTable.Rows
		$result.TableText | Should Be $ExpectedTable.TableText
    }

    It "Markdown table format from pipeline" {
		$result = $TestCase | ConvertTo-Table -TableFormat Markdown
		# $result | Should BeOfType [Table]
		$result.Columns | Should Be $ExpectedTable.Columns
		$result.Rows | Should Be $ExpectedTable.Rows
		$result.TableText | Should Be $ExpectedTable.TableText
    }

    It "Markdown table with -PrintTable option" {
		$result = $TestCase | ConvertTo-Table -TableFormat Markdown -PrintTable
		$result | Should BeOfType [string]
		$result | Should Be $ExpectedTable.TableText
    }
}
