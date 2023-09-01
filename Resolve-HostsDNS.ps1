Clear-Host
# Define an array of server
$remoteComputers="hostname1","hostname2"
# Define an array of DNS addresses to resolve and ping
$dnsAddresses = @("google.com")

$dnsResults=@()
foreach($remoteComputer in $remoteComputers){




# Loop through each DNS address and resolve it on the remote computer
foreach ($address in $dnsAddresses) {
    $dnsResult = Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
        param($dnsAddress)
        Resolve-DnsName -Name $dnsAddress
    } -ArgumentList $address

    # Display the results
    Write-Host "DNS resolution for $address on $remoteComputer :"
    $dnsResult | Format-Table -AutoSize
    Write-Host ""

    # Ping the DNS address from the remote computer
    $pingResult = Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
        param($targetAddress)
        Test-Connection -ComputerName $targetAddress -Count 4 -ErrorAction SilentlyContinue
    } -ArgumentList $address

    if ($pingResult) {
        Write-Host "Ping results for $address from $remoteComputer :"
        $pingResult  | Format-Table -AutoSize
    } else {
        Write-Host "Ping to $address from $remoteComputer failed."
    }

    Write-Host ""
}

}

