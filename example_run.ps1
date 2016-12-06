$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Import-Module (Join-Path $here '\Modules\AppEventAggregator\AppEventAggregator.psm1')

Send-MailIfErrors -AppConfigurationPath (Join-Path $here '\Data\applications.json') `
                  -SmtpConfigurationPath (Join-Path $here '\Data\configuration.xml') `
                  -Treshold 1