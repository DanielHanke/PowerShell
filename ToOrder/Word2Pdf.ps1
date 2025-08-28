$documents_path = 'D:\Data\mail'

$word_app = New-Object -ComObject Word.Application

# This filter will find .doc as well as .docx documents
Get-ChildItem -Path $documents_path -Recurse -Filter *.doc? | ForEach-Object {

    $str = "Guardando item " + $_.FullName 
     Write-Host $str
    $document = $word_app.Documents.Open($_.FullName)

    $pdf_filename = "$($_.DirectoryName)\$($_.BaseName).pdf"

    $document.SaveAs([ref] $pdf_filename, [ref] 17)

    $document.Close()
}

$word_app.Quit()