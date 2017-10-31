#Kenneth Liu 10/30/17

#define field values here
$global:saveLocation = "C:\FaceBook_Expedia_$(get-date -f yyyy-MM-dd-hh-ss-ms).txt"
$global:numberOfPosts = 8
$global:faceBookPageURL = "https://www.facebook.com/pg/expedia/posts/?ref=page_internal"

$VerbosePreference = "continue"

#this function gets a FaceBook page and its latest posts
#this function assumes that the URL for the FaceBook page remains the same and the parent div of the posts 'userContentWrapper' remains the same--however, FaceBook is always making changes.
#$numberOfPosts: The number of posts to limit the data pull to
function Get-WebSiteLatestPosts($numberOfPosts) 
{
    Write-Verbose "Pulling Latest FaceBook Posts"

    $WebResponse = Invoke-WebRequest $global:faceBookPageURL #reference for the website URL for Facebook posts

    $Data = $WebResponse.ParsedHTML

    $Results = @{} #use a hashtable so we can store key=timestamp and value=post content

	Write-Verbose "Please wait while data is being extracted..."
    #We should look for divs with class values containing 'userContentWrapper' to get the latest posts
    $count = 1
    $Data.getElementsByTagName('div') | Where classname -match 'userContentWrapper' | % {

            if($count -ile $numberOfPosts) {
                $TimeStamp = $_.GetElementsByClassName("timestampContent") | Select InnerText #timestampContent class gives a span with the time the post was made
                $Post = $_.GetElementsByClassName("userContent") | Select InnerText  #userContent contains the text of the post
                $Results.Add("Post - " + $count.ToString(), @($TimeStamp.InnerText, $Post.InnerText))

                $count++
            }          
    }

    #sort the results by key value
    $Results = $Results.GetEnumerator() | Sort-Object -Property key

    #instead of returning in the foreach loop above, we return here. There is an issue when returning inside the loop causing the results to double up
    return $Results
}

#formats a collection into JSON format using ConvertTo-Json
#$data: assumes input is a collection type (array, hashtable)
function Format-DataIntoJSON($data) 
{
    if($data -eq $null) 
    {
        Write-Verbose "No data to convert"
    }
    else
    {
        Write-Verbose "Converting Data to JSON"

        %{
            return $data | ConvertTo-Json
         }
    }
}

#writes output to a specified save location. Unescape is used because when converting with ConvertTo-Json it escapes the data
#This assumes that the current user running this script has write access
#$data: JSON text, $saveLocation: location to save output file
function Write-JSONToTextFile($data) 
{
    if($data -eq $null) 
    {
        Write-Verbose "No output to write"
    } 
    else 
    {
        Write-Verbose "Writing Output File to: $global:saveLocation"
        $data | %{ [System.Text.RegularExpressions.Regex]::Unescape($_) } |out-file -Encoding utf8 -FilePath $global:saveLocation

        Write-Verbose "Execution completed!"

    }
}

#call functions here, we call them here because the functions above have to be defined first
$Data = Get-WebSiteLatestPosts($global:numberOfPosts) #returns a collection with the post #, timestamp, and post text
$DataInJSON = Format-DataIntoJSON($Data) #converts a collection to JSON
Write-JSONToTextFile($DataInJSON) #outputs JSON to a file