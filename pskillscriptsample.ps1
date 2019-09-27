Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId "YOUR_SUBSCRIPTION_ID"

$resoureGroupName = "YOUR_RG_NAME"
$websiteName = "YOUR_WEBAPP_NAME"
 
$instances = Get-AzureRmResource -ResourceGroupName $resoureGroupName `
                                 -ResourceType Microsoft.Web/sites/instances `
                                 -ResourceName $websiteName `
                                 -ApiVersion 2018-02-01
 
 
foreach($instance in $instances)
{
    $instanceName = $instance.Name
 
    Write-Host "Site Instance Name : " $instanceName
 
    $processes = Get-AzureRmResource -ResourceGroupName $resoureGroupName `
                                    -ResourceType Microsoft.Web/sites/instances/processes `
                                    -ResourceName $websiteName/$instanceName `
                                    -ApiVersion 2018-02-01
 
    foreach($process in $processes)
    {
        $exeName = $process.Properties.Name
        Write-Host "`tEXE Name : " $exeName
 
        if($exeName -eq "w3wp")
        {
            $processId = $process.Properties.id
            Write-Host "`t`tProcess ID : " $processId
 
            $processDetails = Get-AzureRmResource -ResourceGroupName $resoureGroupName `
                                                    -ResourceType Microsoft.Web/sites/instances/processes `
                                                    -ResourceName $websiteName/$instanceName/$processId `
                                                    -ApiVersion 2018-02-01
 
            Write-Host "`t`tSCM Value : " $processDetails.Properties.is_scm_site
             
            if($processDetails.Properties.is_scm_site -ne $true)
            {
                Write-Host "`t`t`tNot a SCM Process : " $process.Properties.Name
 
                $deleted = Remove-AzureRmResource -ResourceGroupName $resoureGroupName `
                                                    -ResourceType Microsoft.Web/sites/instances/processes `
                                                    -ResourceName $websiteName/$instanceName/$processId `
                                                    -ApiVersion 2018-02-01 -Force
 
                if($deleted -eq $true)
                {
                    Write-Host "`t`t`t`tW3wp process killed" -ForegroundColor Green
                }
                else
                {
                    Write-Host  "`t`t`t`tFailed to kill W3wp process" -ForegroundColor Red
                }
            }
        }
    }
}