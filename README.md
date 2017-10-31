# LIUKEN1
Code Challenge #1

=========================================================
Instructions:

To execute this script, run PowerShell as administrator and 'cd' to the directory of the script.

Once in the same directory as the file, use this command to run the script:
.\LIUKEN1.ps1

If you see this error:

.\LIUKEN1.ps1 : File C:\Users\Kenneth\Desktop\Coding Challenges\LIUKEN1\LIUKEN1.ps1 cannot be loaded because running
scripts is disabled on this system. For more information, see about_Execution_Policies at
http://go.microsoft.com/fwlink/?LinkID=135170.
At line:1 char:1
+ .\LIUKEN1.ps1
+ ~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess

Use this command to allow running scripts on your system:
Set-ExecutionPolicy RemoteSigned
-Type 'Y' for yes

During execution, there will be verbose text telling the user what the current step is in the scraping process.

The final output of the file (by default but can be changed in the script) is saved in the user's C:\ directory.

=========================================================
Rationale of script:

This script uses Invoke-WebRequest to illicit a response from the page. The default URL is set to Expedia's FaceBook Post page.

After a response is received, the script will access the ParsedHTML property of the response. The idea here is to be able to access the HTML directly so we can select the corresponding DIVs for their text--this is seen in the getElementsByTagName('div') to select only the DIVs of the response. In conjunction with selecting only the DIVs, we filter down further to the 'userContentWrapper' class name. In my analysis, stepping through FaceBook's HTML code, 'userContentWrapper' is the parent wrapper of all posts and other information we need like the timestamp, comments, etc.

    The heirarchy for FaceBookPosts is:
        <div class='userContentWrapper'>
            ...
            <div>
                <div class='userContent'> <!-- Post 1 -->
                </div>
                <span class='timestampContent'></span>
            </div>
            
            <div>
                <div class='userContent'> <!-- Post 2 -->
                </div>
                <span class='timestampContent'></span>
            </div>
            ...
        </div>

To store the results, I used a HashTable data structure--the key being the post # (posts are chronologically sorted when pulled from FaceBook so we number them) and the value being an array with two values (timestamp, post text). Due to HashTables naturally being unsorted, I sort the data using an enumerator referencing the key value.

The aim for this script was to extract the FaceBook post's text and timestamp and save it to a text file in JSON format. My next function Format-DataIntoJSON takes the data as a parameter and utilizes the ConvertTo-JSON function to convert it automatically.

After converting to JSON, the last task in my scripts execution process is to save the file to a specified directory. The Write-JSONToTextFile function takes the $data parameter and writes the data specified by the global field value ($global:saveLocation).
The assumption here is that if the user is able to run the script as adminsitrator they should be able to save the file to the C:\ drive by default. The interesting command in the file output line is "%{ [System.Text.RegularExpressions.Regex]::Unescape($_) }"--the reason I included this command is because the ConvertTo-JSON command automatically escapes some special characters in the output (like apostrophes). I use this command to unescape the output to make it more readable. The file is saved as a text file with the datetime appeneded to make it unique.

I chose to make the saveLocation, numberOfPosts, and faceBookPageURL global so it can be used throughout the script--also it allows it to be easily changed by the user to customize the script.