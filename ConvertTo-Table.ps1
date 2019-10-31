function ConvertTo-Table {
	<#.SYNOPSIS
	Covert array of PSCustomObject to text based Table object.
	.DESCRIPTION
	Covert array of PSCustomObject to text based Table object.
	Use when Copy from Format-Table is not enough or when you want Markdown format table text.
	.EXAMPLE
	Get-Process | Select-Object CPU, Name | Sort-Object -Descending | ConvertTo-Table -TableFomat Markdown
	.EXAMPLE
	Get-ChildItem | Select-Object Name, Length, LastWriteTime | ConvertTo-Table -TableFomat Text
	.EXAMPLE
	Get-ChildItem | Select-Object Name, Length, LastWriteTime | ConvertTo-Table -TableFomat Text -PrintTable | Set-Clipboard
	.PARAMETER InputObject
	Array of PSCustomObject you want to convert.
	.PARAMETER TableFormat
	Output Table text format. Text and Markdown is supported.
	.Outputs
	-TableFormat Markdown -PrintTable
	|+-----+-----+-----+
	| A   | B   | C   |
	+-----+-----+-----+
	| a   | b   | c   |
	| aa  | bb  | cc  |
	| aaa | bbb | ccc |
	+-----+-----+-----+
	.Outputs
	-TableFormat Markdown -PrintTable
	| A | B | C |
	| - | - | - |
	| a | b | c |
	| aa | bb | cc |
	| aaa | bbb | ccc |
	#>
	[CmdletBinding()]
	param (
		# Object that you want to convert to table.
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[Object[]]
		$InputObject,

		# Output Rable Format
		[Parameter(Mandatory=$true)]
		[ValidateSet("Text", "Markdown")]
		[string]
		$TableFormat,

		[switch]
		$PrintTable
	)

	begin {
		[Object[]]$Aggregate = @()
	}

	process {
		foreach ($o in $InputObject) {
			$Aggregate += $o
		}
	}

	end {
		[Table]$Table = $null
		if ($TableFormat -eq "Text") {
			$tg = [TextTableGenerator]::New($Aggregate)
			$Table = $tg.GenerateTable()
		} elseif ($TableFormat -eq "Markdown") {
			$tg = [MarkdownTableGenerator]::New($Aggregate)
			$Table = $tg.GenerateTable()
		}

		if ($PrintTable) {
			Write-Output $Table.TableText
		} else {
			Write-Output $Table
		}
	}
}

class Table {
	[string]$TableText
	[int]$Rows
	[int]$Columns

	Table() {
		$this.TableText = "" 
		$this.Rows = 0
		$this.Columns = 0
	}
}

# TableGenerator Interface
class TableGenerator {
	[Object[]]$Data

	[Table] GenerateTable() {
		throw "Required Interface Implements."
	}
}

# Concrete class of TableGenerator
# This class generate table with text format
# Example.
# +--------------+-----------+-------------------------+
# | IP           | Hostname  | Usename                 |
# +--------------+-----------+-------------------------+
# | 10.10.10.100 | xxxxxxxxx | XXXXXXXXXXXXXXXXXXXXXXX |
# | 172.16.0.1   | yyyyyyyyy | YYYYYYYYYYYYYYYYYYYYYYY |
# +--------------+-----------+-------------------------+
 
class TextTableGenerator : TableGenerator {
	[int[]]$numOfCharsPerColumn
	[string[]]$headerProps

	TextTableGenerator([Object[]]$Data) {
		$this.Data = $Data
	}

	[Table] GenerateTable() {
		$this.PrepareTable()
		$Table = [Table]::New()
		$Table.Columns = $this.headerProps.Count
		$Table.Rows = $this.Data.Count

		# Generate header string
		$Table.TableText = $this.makeBoundary()
		$Table.TableText += $this.makeRow($this.headerProps)
		$Table.TableText += $this.makeBoundary()

		# Generate Rows string
		foreach ($d in $this.Data) {
			$row = @()
			foreach ($prop in $this.headerProps) {
				$row += $d.$prop
			}
			$Table.TableText += $this.makeRow($row)
		}

		# Generate Footer String
		$Table.TableText += $this.makeBoundary()

		return $Table
	}

	hidden [void] PrepareTable() {
		$this.setHeaderProps()
		$this.computeNumOfChars()

		Write-Verbose "Header: $($this.headerProps)"
		Write-Verbose "NumOfCharsPerColumn : $($this.numOfCharsPerColumn)"
	}

	hidden [void] computeNumOfChars() {
		$propsCount = $this.headerProps.Count
		$this.numOfCharsPerColumn = @()

		for ($i = 0; $i -lt $propsCount; $i++) {
			$max = 0
			$propName = $this.headerProps[$i]
			foreach ($r in $this.Data) {
				$len = $this.getStringDiplayWidth($r.$propName)
				if ($max -lt $len) {
					$max = $len
				}
			}
			$len = $this.getStringDiplayWidth($propName)
			if ($max -lt $len) {
				$max = $len
			}
			$this.numOfCharsPerColumn += $max
		}
	}

	hidden [void] setHeaderProps() {
		$props = $this.Data[0] | Get-Member -MemberType NoteProperty
		$this.headerProps = @()
		foreach ($p in $props) {
			$this.headerProps += $p.Name
		}
	}

	hidden [string] makeRow($row) {
		$s = "|"
		for ($i = 0; $i -lt $this.headerProps.Count; $i++) {
			$s += " $($this.rJust($row[$i], ' ', $this.numOfCharsPerColumn[$i])) |"
		}
		$s += "`r`n"
		return $s
	}

	hidden [string] makeBoundary() {
		$s = "+"
		for ($i = 0; $i -lt $this.headerProps.Count; $i++) {
			$boundary = '-' * ($this.numOfCharsPerColumn[$i] + 2)
			$s += "$boundary+"
		}
		$s += "`r`n"
		return $s
	}

	hidden [string] rJust([string]$str, [string]$char, [int]$n) {
		if ($str.Length -gt $n) {
			return $str.SubString(0, $n)
		}

		$padLen = $n - $str.Length
		return $str + ($char*$padLen)
	}

	hidden [int] getStringDiplayWidth([string]$str) {
		$wide = [Microsoft.VisualBasic.Strings]::StrConv($str, [Microsoft.VisualBasic.VbStrConv]::Wide)
		$width = 0
		for ($i=0; $i -lt $str.length; $i++) {
			$width++
			if ($str[$i] -eq $wide[$i]) { $width++ }
		}
		return $width
	}
}

class MarkdownTableGenerator : TableGenerator {
	[string[]]$headerProps

	MarkdownTableGenerator([Object[]]$Data) {
		$this.Data = $Data
	}

	[Table] GenerateTable() {
		$this.setHeaderProps()
		$Table = [Table]::New()

		$Table.Columns = $this.headerProps.Count
		$Table.Rows = $this.Data.Count

		$Table.TableText = $this.makeRow($this.headerProps)
		$Table.TableText += $this.makeBoundary()
		foreach ($d in $this.Data) {
			$row = @()
			foreach ($prop in $this.headerProps) {
				$row += $d.$prop
			}
			$Table.TableText += $this.makeRow($row)
		}

		return $Table
	}

	hidden [void] setHeaderProps() {
		$props = $this.Data[0] | Get-Member -MemberType NoteProperty
		$this.headerProps = @()
		foreach ($p in $props) {
			$this.headerProps += $p.Name
		}
	}

	hidden [string] makeRow($row) {
		$s = "|"
		for ($i = 0; $i -lt $this.headerProps.Count; $i++) {
			$s += " $($row[$i]) |"
		}
		$s += "`r`n"
		return $s
	}

	hidden [string] makeBoundary() {
		$s = "|"
		for ($i = 0; $i -lt $this.headerProps.Count; $i++) {
			$boundary = "-" * $this.headerProps[$i].Length
			$s += " $boundary |"
		}
		$s += "`r`n"
		return $s
	}
}
