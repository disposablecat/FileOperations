function Select-StringFileStream{
<#
.SYNOPSIS
     Return an array with all string matches in a file.  

.DESCRIPTION
   Return an array with all string matches in a file. Will include line number and match

.PARAMETER Pattern
    The string you're looking for

.PARAMETER File
    The full patch of the file you're looking for

.NOTES
    Version:        1.0
    Author:         disposablecat
    Purpose/Change: Initial script development

.EXAMPLE
   Select-StringFileStream -Pattern "test" -File "C:\logs\log1.txt"

#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    
    #Define parameters
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$Pattern,
        
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$File

    )

    Begin
    {
        $returnarray = @()
        $returnobject = New-Object -TypeName PSObject
        
    }

    Process
    {

        Try
        {
            
            $filestream = [System.IO.File]::OpenRead($File)
            $streamreader = New-Object System.IO.StreamReader($filestream)

            $string = $streamreader.ReadToEnd()

            $streamreader.Close()
            $filestream.Close()

            if($string -match $Pattern) {

                $matches = [regex]::Matches($string, $Pattern)

                $previousIndex = 0
                $previousLineCount = 0

                foreach($match in $matches) {
                    $lineCount = $string.Substring($previousIndex, $match.Index - $previousIndex).Split("`n").Count + $previousLineCount
                    $previousIndex = $match.Index
                    $previousLineCount = $lineCount - 1 # to account for the extra bippety every iteration because it's a split array

                    #Write-Host "$lineCount - $($match.Value)"
                    $returnobject | Add-Member -MemberType NoteProperty -Name Line -Value $lineCount -Force
                    $returnobject | Add-Member -MemberType NoteProperty -Name Match -Value $match.Value -Force
                    $returnarray += $returnobject
                }
                
                $matches = $null
                return $returnarray
            }
            else {
                Write-Host "No match"
            }

            $string = $null
            [system.gc]::Collect()
            
        }
        Catch
        {
            #Catch any error.
            Write-Verbose "Entering Catch Statement"
            Write-Host  “Caught an exception:” -ForegroundColor Red
            Write-Host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
            Write-Host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
            Write-Host “Exception ItemName: $($_.Exception.ItemName)” -ForegroundColor Red
        }
     
    }

}

function Get-ContentFS{
<#
.SYNOPSIS
     Return an array with all lines in a file.  

.DESCRIPTION
   Return an array with all lines in a file. This uses file streaming is much faster than Get-Content

.PARAMETER File
    The full patch of the file you're looking for

.NOTES
    Version:        1.0
    Author:         Christopher Grant
    Creation Date:  10/18/2016
    Purpose/Change: Initial script development

.EXAMPLE
   Get-ContentFS -File "C:\logs\log1.txt"

#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    
    #Define parameters
    Param
    (
        # Param1 help description
        
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$File

    )

    Begin
    {
        
        $list = New-Object System.Collections.Generic.List[System.String]
        
    }

    Process
    {

        Try
        {
            
            foreach ($line in [System.IO.File]::ReadLines($File))
            {
                $list.Add("$line")
                  
            }
            return $list

            
        }
        Catch
        {
            #Catch any error.
            Write-Verbose "Entering Catch Statement"
            Write-Host  “Caught an exception:” -ForegroundColor Red
            Write-Host “Exception Type: $($_.Exception.GetType().FullName)” -ForegroundColor Red
            Write-Host “Exception Message: $($_.Exception.Message)” -ForegroundColor Red
            Write-Host “Exception ItemName: $($_.Exception.ItemName)” -ForegroundColor Red
        }
     
    }

}