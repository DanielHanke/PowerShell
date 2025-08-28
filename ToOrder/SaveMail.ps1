$Outlook = New-Object -comobject Outlook.Application
$word = New-Object -ComObject Word.Application
$ns = $Outlook.GetNameSpace("MAPI")

$index = 1

Function Listfolders
{ 
  param($Folders, $Indent)

  ForEach ($Folder in $Folders | sort-object name)
  {
    write-host $Indent$($Folder.Name)" ("$($Folder.Items.Count)")"
    Listfolders $Folder.Folders $Indent"  " 
  }
}

Function PrintInbox
{ 
  param($Folders )

  ForEach ($Folder in $Folders | sort-object name)
  {
    if ($Folder.Name -eq 'AUT' )
    {
      Write-Host "PROCESANDO AUT"
      

      ForEach ($item in $Folder.Items | sort-object name)
      {
        $str = "Guardando item " + $index.ToString() + " de " + $Folder.Items.Count
        Write-Host $str

        $fileStr = 'D:\Data\mail\8\' + $index.ToString() + '.doc'
        $item.SaveAs( $fileStr,  4 ) #word

        #$doc = $word.Documents.Open($fileStr)
        #$fileStr = $file + '.pdf'
        #$doc.SaveAs($fileStr, 17)
        #$doc.Close()

        $index = $index + 1

      }
    }
    PrintInbox $Folder.Folders
  }
}

PrintInbox $ns.Folders
#ListFolders $ns.Folders ""
$str = "Termine"
Write-Host $str