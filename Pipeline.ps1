# objects piped from one commadnto another get-data | convert-data | save-data

# -PassThru switch

#mutliple pipelines
# ErrorPipeline, WarningPipeline, VerbosePipeline, DebugPipeline
# not all cmdlets designed to use it

# controlled by preference variables

# output
Get-Service | Out-File -FilePath 'C:\Temp\service_dump.txt' -Append 

# stream redirection 
# Stream = value
# Pipeline (success) =1
# Errors = 2
# Warning = 3
# Verbose = 4
# Debug = 5

# write >
# append >>
# merge >&

Get-WmiObject wind32_logicaldisk 2>err.txt 4>verbose.txt

Get-WmiObject wind32_logicaldisk 2>&1 1>data.txt # any erros and output will be in the same file, can only merge to sucess stream


# Sometimes pipeline is not good for given task - ForEach
