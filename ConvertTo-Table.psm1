$src = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath '*.ps1') -Recurse -ErrorAction Stop)

Foreach ($s in $src) {
        if ($s.Name -Match ".Test.") {
                continue
        }

        if ($s.Name -Match "test") {
                continue
        }

        try {
                . $s.FullName
        }
        catch {
                throw "Load Error [$($s.FullName)]"
        }
}

$functions = @("ConvertTo-Table")
Export-ModuleMember -Function $functions
