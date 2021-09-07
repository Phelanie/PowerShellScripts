$CurrentTime = (Get-Date).ToFileTime()
$CalculatedProperty = @{
    Label='AccountExpires'
    Expression = { if (!$_.AccountExpires -or $_.AccountExpires -ge [datetime]::MaxValue.ToFileTime()) {
                       "Never"
                   } 
                   elseif ($_.AccountExpires -le $CurrentTime) {
                       "Expired"
                   }
                   else { 
                       [datetime]::FromFileTime($_.AccountExpires)
                   }
                 }
}

$users = Get-ADUser -filter "Enabled -eq '$true'" -Properties AccountExpires |
    Select-Object SamAccountName,Name,$CalculatedProperty
$users | Where AccountExpires -eq 'Expired' | Foreach-Object {
    Disable-ADAccount -Identity $_.SamAccountName -WhatIf
}