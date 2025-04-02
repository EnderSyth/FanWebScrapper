# PowerShell script to convert CSV to text file
# Extracts User, Chapter, and Comment columns

# Add Windows Forms assembly for file dialog
Add-Type -AssemblyName System.Windows.Forms

# Create and configure the open file dialog
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$documentsPath = [Environment]::GetFolderPath("MyDocuments")
$openFileDialog.InitialDirectory = $documentsPath
$openFileDialog.Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"
$openFileDialog.Title = "Select CSV file"

# Show the dialog and process the file if user didn't cancel
if ($openFileDialog.ShowDialog() -eq 'OK') {
    $inputFile = $openFileDialog.FileName
    $outputFile = [System.IO.Path]::ChangeExtension($inputFile, "txt")
    
    # Import the CSV file
    $csvData = Import-Csv -Path $inputFile
    
    # Create or overwrite the output text file - using UTF8 encoding without BOM
    $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($outputFile, "", $utf8NoBomEncoding)
    
    # Create a file for skipped comments
    $skippedOutputFile = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($outputFile), 
        "skipped-" + [System.IO.Path]::GetFileName($outputFile))
    [System.IO.File]::WriteAllText($skippedOutputFile, "", $utf8NoBomEncoding)
    
    # Process each row and write to the text file
    $commentsToProcess = @()
    $skippedComments = @()
    $skippedCount = 0
    
    foreach ($row in $csvData) {
        # Handle different possible column names and trim whitespace
        $user = if ($row.PSObject.Properties.Name -contains "User") { $row.User.Trim() } else { "Unknown User" }
        
        # Handle chapter with or without "on " prefix and trim whitespace
        $chapter = if ($row.PSObject.Properties.Name -contains "Chapter") { 
            $chapterText = $row.Chapter.Trim()
            # Remove "on " prefix if present
            if ($chapterText -match "on (.+)") {
                $matches[1].Trim()
            } else {
                $chapterText
            }
        } else { "Unknown Chapter" }
        
        # Extract chapter number for sorting
        $chapterNumber = 0
        if ($chapter -match "chapter (\d+)") {
            $chapterNumber = [int]$matches[1]
        }
        
        # Handle different comment column names and trim whitespace
        $comment = if ($row.PSObject.Properties.Name -contains "Comment") { 
            $row.Comment.Trim() 
        } elseif ($row.PSObject.Properties.Name -contains "Comment Body") { 
            $row."Comment Body".Trim() 
        } else { 
            "No comment available" 
        }
        
        # Remove excessive whitespace within the comment (multiple spaces, tabs)
        $comment = $comment -replace '\s+', ' '
        
        # Count words in the comment
        $wordCount = ($comment -split '\s+').Count
        
        # Skip comments with fewer than specified words
        if ($wordCount -lt 15) {
            $skippedCount++
            $skippedComments += [PSCustomObject]@{
                User = $user
                Chapter = $chapter
                ChapterNumber = $chapterNumber
                Comment = $comment
                WordCount = $wordCount
            }
            continue
        }
        
        # Add to array for sorting
        $commentsToProcess += [PSCustomObject]@{
            User = $user
            Chapter = $chapter
            ChapterNumber = $chapterNumber
            Comment = $comment
        }
    }
    
    # Sort comments by chapter number if filename starts with FF
    if ([System.IO.Path]::GetFileName($inputFile).StartsWith("FF")) {
        $commentsToProcess = $commentsToProcess | Sort-Object -Property ChapterNumber
    }
    
    # Write sorted comments to file
    foreach ($item in $commentsToProcess) {
        # Prepare content with proper line endings
        $content = "$($item.User) - $($item.Chapter)`r`n$($item.Comment)`r`n-`r`n"
        
        # Append to file with proper encoding
        [System.IO.File]::AppendAllText($outputFile, $content, $utf8NoBomEncoding)
    }
    
    # Write skipped comments to separate file
    foreach ($item in $skippedComments) {
        # Prepare content with proper line endings
        $content = "$($item.User) - $($item.Chapter) [Words: $($item.WordCount)]`r`n$($item.Comment)`r`n-`r`n"
        
        # Append to file with proper encoding
        [System.IO.File]::AppendAllText($skippedOutputFile, $content, $utf8NoBomEncoding)
    }
    
    Write-Host "Conversion complete! Output saved to $outputFile"
    Write-Host "Skipped $skippedCount comments (saved to $skippedOutputFile)"
    
    # Get file content for more accurate estimation
    $fileContent = Get-Content -Path $outputFile -Raw
    $wordCount = ($fileContent -split '\s+').Count
    $fileSize = (Get-Item -Path $outputFile).Length
    
    # Multiple estimation methods
    $tokensByFileSize = [Math]::Ceiling($fileSize / 4)
    $tokensByWordCount = [Math]::Ceiling($wordCount / 0.75)  # ~0.75 words per token for English
    
    Write-Host "File size: $fileSize bytes"
    Write-Host "Word count: $wordCount"
    Write-Host "Estimated tokens (by file size): $tokensByFileSize"
    Write-Host "Estimated tokens (by word count): $tokensByWordCount (more accurate)"
} else {
    Write-Host "No file selected. Exiting."
}
