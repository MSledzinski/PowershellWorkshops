# Do you know what is the difference between those functions

function First()
{
    Write-Host "Hello"
}

function Second()
{
    Write-Output "Hello"
}

function Second_and_a_Half()
{
    Write-Output @(,"Hello")
}

function Third()
{
    "Hello"
}

function Fourth()
{
    return "Hello"
}

First
Second
Second_and_a_Half
Third
Fourth