$Outlook = New-Object -comobject Outlook.Application
$ns = $Outlook.GetNameSpace("MAPI")

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
    if ($Folder.Name -eq 'Inbox' )
    {
      Write-Host "Encontre un Inbox"
      
      ForEach ($item in $Folder.Items | sort-object name)
      {
        $fileStr = 'D:\Data\mail\' + $item.Subject + '.msg'
        $item.SaveAs( $fileStr,  5 )
      }
    }
    PrintInbox $Folder.Folders
  }
}

PrintInbox $ns.Folders
#ListFolders $ns.Folders ""