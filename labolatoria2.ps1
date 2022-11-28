$global:resourceGroup = "ResourceGroup"
$global:path = "C:\wit"
$global:location = "West Europe"

function CreateFolder {
    if (Test-Path $path) {
        Write-Host "istnieje lokalizacja" $path -ForegroundColor Red
    }

    else {
        New-Item -Path $path -ItemType Directory -Force -Verbose
    }
}

function CheckOrCreateCSV {
    Param(
        [string]$global:pathCSV = "\vm-to-do-list.csv"
    )

    CreateFolder

    if (Test-Path ($path + $pathCSV)) {
        Write-Host "istnieje lokalizacja" ($path + $pathCSV) -ForegroundColor Red
    }

    else {
        New-Item -Path ${path} -Name "$pathCSV" -Verbose
        Add-Content -Path ($path + $pathCSV) -value "Nazwa,ResourcesGroup" -Verbose
    }
}

#Tworzenie ResourceGroup
function CreateResourceGroup {
    $importVM = Import-csv -Path ($path + $pathCSV) -Delimiter ","
    foreach ($vm in $importVM) {
        New-AzResourceGroup -Name $vm.ResourcesGroup -Location $location -Verbose
    }
}

#Tworzenie nowej maszynyn wirtualnej
function CreateVM {

    $importVM = Import-csv -Path ($path + $pathCSV) -Delimiter ","
    foreach ($vm in $importVM) {
        New-AzVM `
            -ResourceGroupName  $vm.ResourcesGroup `
            -Name $vm.Nazwa  `
            -Size "Standard_L4s" `
            -Location "West Europe" `
            -VirtualNetworkName "VNet" `
            -SubnetName "Subnet"  `
            -SecurityGroupName "NewtorkSecurityGroup"  `
            -Credential $credential `
            -OpenPorts 3389 `
            -Verbose

        New-AzPublicIpAddress -Name "PublicIpAddress"  -ResourceGroupName $vm.ResourcesGroup `
            -Location $location -AllocationMethod Static -Verbose
    }
}


function Menu {
    cls
    $userPrompt = Read-Host "Instrukcja jak stworzyć maszynę wirtualną na platformie Azure. `
    1: Instalacja modulu Azure. `
    2: Logowanie do strony Azure. `
    3: Tworzenie konta administratora dla maszyn wirtualnych. `
    4: Tworzenie grupy zasobow jesli podane w pliku CSV.`
    5: Tworzenie maszyn wirutalnych z pliku CSV."
    if ($userPrompt -eq "1") {
        cls
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Verbose
        Install-Module Az -Verbose
    }
    elseif ($userPrompt -eq "2") {
        cls
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Verbose
        Import-Module Az.Accounts -Verbose
        Connect-AzAccount -Verbose
    }
    elseif ($userPrompt -eq "3") {
        cls
        $global:credential = Get-Credential -Verbose
    }
    elseif ($userPrompt -eq "4") {
        cls
        CheckOrCreateCSV
        CreateResourceGroup
    }
    elseif ($userPrompt -eq "5") {
        cls
        CheckOrCreateCSV
        CreateVM
    }
    else {
        Write-Host "Proszę spróbować ponownie."
    }

}