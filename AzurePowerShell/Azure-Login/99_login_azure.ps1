########################################################################
# Date : 2018-11-02
# Azure Login
# 
########################################################################
function PCW-Get-AzureLogin {
    Add-AzureRmAccount

    # Select  subscr
    $subscription = Get-AzureRmSubscription
    Write-Host "Your Subscriptions is"

    for ($i=1; $i -lt $subscription.Count + 1; $i++) {
        $print = $i.ToString() + ". [ " + $subscription[$i - 1].Name + " ]"
        Write-Host $print
    }

    Write-Host ""

    ## Select Subscription
    while($true) {
        try {
            Write-Host "Select Your Subscritpion for use"
            [int]$selectSub = Read-Host
            ## -1, -2, 0 등 숫자를 입력해도 구독이 선택되어 추가한 코드...
            if ($selectSub -le 0) {
                $selectSub = 10000
            }
            $yourSub = Select-AzureRmSubscription -Subscription $subscription.Id[$selectSub - 1] `
                                        -TenantId $subscription.TenantId[$selectSub - 1] `
                                        -Name $subscription.Name[$selectSub - 1] `
                                        -Force
            Write-Host $yourSub.Name
            break;
        } catch [System.Exception] {
            Write-Host "Wrong Selection !!" -ForegroundColor Red
            #Write-Host $_.Exception.GetType().FullName -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            #Write-Host ""
        }
    }

    return $yourSub
}