# Este script analiza un repo de GitHub, y genera un archivo LaTeX con el listado de issues,
# los eventos y los comentarios. Tambien hace un pequeño análisis, pero que todavía necesita
# fine tunning

#
# Con estos parámetros se puede llamar al script para analizar un repo cualquiera sin tocar el 
# código
#
 param (
    [string]$RepoUserName = "TrendCPRepo",
    [string]$RepoName = "TREFILA-LIT3-BME-SIERRA",
    [string]$pdfPath = $PSScriptRoot + "\latex\",
    [string]$pdfFile = "issues.tex" 
 )


$pdfFile = $pdfPath + $RepoUserName + $RepoName +"_" + $pdfFile

#
# arrays con tiempos para generar un gráfico al final del script
#
$TaskArray = New-Object System.Collections.Generic.List[System.Object]
$TimeArray = New-Object System.Collections.Generic.List[System.Object]
$DateCloseArray = New-Object System.Collections.Generic.List[System.Object]
$global:img_num = 1

# Toda la basura que va al ppio del doc LaTeX
function WriteLatexPreamble{

    WriteLatex "\usepackage[]{arimo}"
    WriteLatex "\usepackage[spanish]{babel}"
    WriteLatex "\renewcommand*\familydefault{\sfdefault}"
    WriteLatex "\usepackage[T1]{fontenc}"
    WriteLatex "\usepackage{fontawesome}"
    WriteLatex "\usepackage[x11names]{xcolor}"
    WriteLatex "\setlength{\parindent}{0em}"
    WriteLatex "\usepackage[most]{tcolorbox}"
    WriteLatex "\usepackage{geometry}"
    WriteLatex "\geometry{margin=0.5in}"
    WriteLatex "\usepackage[bookmarksopen=true,bookmarksnumbered=true,bookmarksopenlevel=4]{hyperref}"
    WriteLatex "\hypersetup{hidelinks}"
    WriteLatex "\usepackage{tikz}"
    WriteLatex "\usepackage{pgfplots}"
    WriteLatex "\usetikzlibrary{calc,positioning,arrows,shapes,shadows,fit,patterns,quotes,spy,matrix, decorations.pathmorphing,shadings}"
    WriteLatex "\tikzset{ "
    WriteLatex "	table/.style={"
    WriteLatex "		matrix of nodes,"
    WriteLatex "		row sep=-\pgflinewidth,"
    WriteLatex "		column sep=-\pgflinewidth,"
    WriteLatex "		nodes={"
    WriteLatex "			rectangle,"
    WriteLatex "			draw=black,"
    WriteLatex "			align=center,"
    WriteLatex "			minimum height=3.5em"
    WriteLatex "		},"
    WriteLatex "		minimum height=1.5em,"
    WriteLatex "		text depth=0.5ex,"
    WriteLatex "		text height=2ex,"
    WriteLatex "		nodes in empty cells,"
    WriteLatex "		%%"
    WriteLatex "		every even row/.style={"
    WriteLatex "			nodes={fill=gray!20}"
    WriteLatex "		},"
    WriteLatex "		column 1/.style={"
    WriteLatex "			nodes={text width=2em,font=\bfseries}"
    WriteLatex "		},"
    WriteLatex "		row 1/.style={"
    WriteLatex "			nodes={"
    WriteLatex "				fill=Green4,"
    WriteLatex "				text=white,"
    WriteLatex "				font=\bfseries"
    WriteLatex "			}"
    WriteLatex "		}"
    WriteLatex "	}"
    WriteLatex "}"
    WriteLatex "\usepackage[utf8]{inputenc}"
    WriteLatex "\DeclareUnicodeCharacter{1F44D}{\faThumbsUp}"
    WriteLatex "\DeclareUnicodeCharacter{0002}{}"
    WriteLatex "\usepackage[explicit]{titlesec}"
    WriteLatex "\titleformat{\section}[block]%"
    WriteLatex "{\huge\bfseries%"
    WriteLatex "	\tikz[overlay] \shade[left color=LemonChiffon1,right color=Blue1,] (0,-1ex) rectangle (\textwidth,1em);}%    "
    WriteLatex "{\thesection}%                   "
    WriteLatex "{1em}%"
    WriteLatexVerbatim "{\textcolor{black}{\hspace{0.4em}#1}}"
    WriteLatex ""
    WriteLatex "\makeatletter"
    WriteLatex "\def\vhrulefill{\leavevmode\leaders\hrule height 1ex depth \dimexpr0.4pt-0.7ex\hfill\kern\z@}"
    WriteLatex "\makeatother"
    WriteLatex ""
    WriteLatex "\titleformat{\subsection}[block]%"
    WriteLatex "{\large\bfseries}%"
    WriteLatexVerbatim "{}{0pt}{{\thesubsection} - #1}%"
    WriteLatex "\usepackage{sansmath}"
    WriteLatex "\pgfplotsset{"
    WriteLatex "	tick label style = {font=\sansmath\sffamily},"
    WriteLatex "	every axis label = {font=\sansmath\sffamily},"
    WriteLatex "	legend style = {font=\sansmath\sffamily},"
    WriteLatex "	label style = {font=\sansmath\sffamily}"
    WriteLatex "}"
}

function WriteLatexVerbatim{

    param (
        $line
    )

    #Write-Output $line  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
    if ($line){
        Write-Output $line  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
    }
}


function WriteLatex{

    param (
        $line
    )

    #Write-Output $line  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
    if ($line){

        # images en body
        if ($line.IndexOf("![Image]") -gt 0){
            while ($line.IndexOf("![Image]") -gt 0){
                $startImageTag = $line.IndexOf("![Image]")
                $startImageUri = $line.IndexOf("![Image]") + 9
                $endImageUri = $line.substring( $startImageUri).IndexOf(")")
                $outputFile = $PSScriptRoot +"\latex\img\" + $global:img_num.ToString() + ".jpg"
                $img = Invoke-RestMethod -Method get -Uri $line.substring( $startImageUri, $endImageUri) -Headers $headers -OutFile $outputFile
                $str = "\includegraphics[width=\textwidth]{./img/" + + $img_num.ToString() + ".jpg" + "}"
                $line = $line.replace( $line.substring( $startImageUri-9, $endImageUri+10), $str) 
                $global:img_num = $global:img_num + 1
            }        
        }
        Write-Output $line.replace("_","\textunderscore ").replace("#","\# ")  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
    }
}


function WriteSectionLatex{

    param ($line)
    if ($line){
        $str = "\section{" + $line.replace("_","\textunderscore ").replace("#","\# ") + "}"
        }
    WriteLatex $str
}

function WriteSubSectionLatex{

    param ($line)
    if ($line){
        #$str = "\subsection{" + $line.replace("_","\textunderscore ").replace("#","\# ") + "}"
        $str = "\subsection{" + $line.replace("_","\textunderscore ").replace("#"," ") + "}"
        }
    WriteLatex $str
}


function DrawGraph{


    WriteLatex "\resizebox{\textwidth}{!}{%"
    WriteLatex "\begin{tikzpicture}"
    WriteLatex "    \begin{axis}["
    WriteLatex "            		x tick label style={"
    WriteLatex "        		/pgf/number format/1000 sep=},"
    WriteLatex "        	ylabel=dias,"
    WriteLatex "        	xlabel=tarea,"
    WriteLatex "        	enlargelimits=0.05,"
    WriteLatex "        	legend style={font=\sansmath\sffamily,at={(0.5,0)},"
    WriteLatex "        		anchor=north,legend columns=-1},"
    WriteLatex "        	ybar interval=0.8,"
    WriteLatex "]"
    WriteLatex "\addplot+ coordinates {"
    
    For ($i=0; $i -lt $TimeArray.Count; $i++) {
        #$line = "(" + $TaskArray[$i].ToString() +"," + $TimeArray[$i].ToString() + ")"
        if ($TimeArray[$i] -lt 0){
            $line = "(" + ($i+1).ToString() +", 0)"
        }
        else{
            $line = "(" + ($i+1).ToString() +"," + $TimeArray[$i].ToString() + ")"
        }
        WriteLatex $line
    }    
    WriteLatex "};"
    WriteLatex "    \end{axis}"
    WriteLatex "\end{tikzpicture}"
    WriteLatex "}"


    WriteLatex "\begin{enumerate}"
    For ($i=0; $i -lt $TimeArray.Count; $i++) {
        $line = "\item Tarea nº \textbf{" + $TaskArray[$i].ToString() + "} = \textbf{\textcolor{Blue4}{" + $TimeArray[$i].ToString() + "}} horas." 
        WriteLatex $line
    }    
    WriteLatex "\end{enumerate}"
}

# Timeline graph functions
function StartTimelineGraph{

    WriteLatex "\resizebox{\textwidth}{!}{%"
    WriteLatex "\begin{tikzpicture}"
    WriteLatex "    \begin{axis}["
    WriteLatex "            		x tick label style={"
    WriteLatex "        		/pgf/number format/1000 sep=},"
    WriteLatex "        	ylabel=horas,"
    WriteLatex "        	xlabel=tarea,"
    WriteLatex "        	enlargelimits=0.05,"
    WriteLatex "        	legend style={font=\sansmath\sffamily,at={(0.5,0)},"
    WriteLatex "        		anchor=north,legend columns=-1},"
    WriteLatex "        	ybar interval=0.8,"
    WriteLatex "]"
}

function SetTimelineGraphData{
    param ($xvalue, $yvalue)

    WriteLatex "\addplot+ coordinates {"
    
        if ($yvalue -lt 0){
            $line = "(" + ($xvalue).ToString() +", 0)"
        }
        else{
            $line = "(" + ($xvalue).ToString() +"," + ($yvalue).ToString() + ")"
        }
        WriteLatex $line
}    

function EndTimelineGraph{
    WriteLatex "};"
    WriteLatex "    \end{axis}"
    WriteLatex "\end{tikzpicture}"
    WriteLatex "}"
}


function DrawGraph{


    WriteLatex "\resizebox{\textwidth}{!}{%"
    WriteLatex "\begin{tikzpicture}"
    WriteLatex "    \begin{axis}["
    WriteLatex "            		x tick label style={"
    WriteLatex "        		/pgf/number format/1000 sep=},"
    WriteLatex "        	ylabel=horas,"
    WriteLatex "        	xlabel=tarea,"
    WriteLatex "        	enlargelimits=0.05,"
    WriteLatex "        	legend style={font=\sansmath\sffamily,at={(0.5,0)},"
    WriteLatex "        		anchor=north,legend columns=-1},"
    WriteLatex "        	ybar interval=0.8,"
    WriteLatex "]"
    WriteLatex "\addplot+ coordinates {"
    
    For ($i=0; $i -lt $TimeArray.Count; $i++) {
        #$line = "(" + $TaskArray[$i].ToString() +"," + $TimeArray[$i].ToString() + ")"
        if ($TimeArray[$i] -lt 0){
            $line = "(" + ($i+1).ToString() +", 0)"
        }
        else{
            $line = "(" + ($i+1).ToString() +"," + $TimeArray[$i].ToString() + ")"
        }
        WriteLatex $line
    }    
    WriteLatex "};"
    WriteLatex "    \end{axis}"
    WriteLatex "\end{tikzpicture}"
    WriteLatex "}"


    WriteLatex "\begin{enumerate}"
    For ($i=0; $i -lt $TimeArray.Count; $i++) {
        $line = "\item Tarea nº \textbf{" + $TaskArray[$i].ToString() + "} = \textbf{\textcolor{Blue4}{" + $TimeArray[$i].ToString() + "}} horas." 
        WriteLatex $line
    }    
    WriteLatex "\end{enumerate}"
}







$accessToken = "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"

$authenticationToken = [System.Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$accessToken"))
    $headers = @{
        "Authorization" = [String]::Format("Basic {0}", $authenticationToken)
        "Accept"  = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
        "Content-Type" = "application/json"
    }

function GetIssues{
   
    param ($state)



    # primero acceder a los issues
    $issuesAPIUri = "https://api.github.com/repos/" + $RepoUserName + "/" + $RepoName +"/issues?state=" + $state

    $issues = Invoke-RestMethod -Method get -Uri $issuesAPIUri -Headers $headers 



    #ciclar a traves de los issues
    $TotalHours = 0
    For ($i=0; $i -lt $issues.Count; $i++) {
        $line = "Procesando " + ($i+1).ToString() + " de " + $issues.Count.ToString()
        Write-Output $line
       
        Write-Output "% ┌──────────────────────────────────────────────────────────────┐" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
        Write-Output "% │ a. Issue                                                     │" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
        Write-Output "% └──────────────────────────────────────────────────────────────┘" | Out-file -FilePath $pdfFile -Encoding utf8 -Append

        
        $line = $issues[$i].title + " (" + $issues[$i].number + ")"
        WriteSubSectionLatex $line

        $line = "\par \textbf{Autor}: " + "\textcolor{blue}{ " + $issues[$i].user.login + "}"
        WriteLatex $line
        $line = "\par \textbf{Fecha creacion}: " + "\textcolor{blue}{ " + ([datetime]$issues[$i].created_at).ToString('dd/MM/yyyy HH:mm') + "}"
        WriteLatex $line
        #if ($issues[$i].closed_at){
        #    $line = "\par \textbf{Fecha cerrado}: " + "\textcolor{blue}{ " + $issues[$i].close_at + "}"
        #    WriteLatex $line
        #    }
        #else{
        #    $line = "\par \textbf{Fecha cerrado}: " + "\textcolor{blue}{ sin cerrar }"
        #    WriteLatex $line
        #}
        if ($issues[$i].body.Length -gt 0){
            #$line = "\par \textbf{Descripcion}: \\\\"
            #WriteLatex $line
            #$line = "\noindent\fbox{%"
            #WriteLatex $line
            #$line = "\parbox{\textwidth}{%"
            #WriteLatex $line
            #$line = $issues[$i].body
            #WriteLatex $line
            #$line = "}%"
            #WriteLatex $line
            #$line = "}"
            #WriteLatex $line
            $line = "\begin{tcolorbox}["
	        WriteLatex $line
            $line = "    colback=Snow2,"
	        WriteLatex $line
            $line = "    colframe=DeepSkyBlue3,"
            WriteLatex $line
	        $line = "    title=My nice heading,"
            WriteLatex $line
	        $line = "    title=" + [datetime]$issues[$i].created_at + "]"
            WriteLatex $line
	        $line = $issues[$i].body
            WriteLatex $line
            $line = "\end{tcolorbox}"                     
            WriteLatex $line
        }


        #$events = Invoke-RestMethod -Method get -Uri $issues[$i].events_url -Headers $headers 
        $events = Invoke-RestMethod -Method get -Uri $issues[$i].timeline_url -Headers $headers 
        #Write-Output $events

        Write-Output "% ┌──────────────────────────────────────────────────────────────┐" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
        Write-Output "% │ a.1. Events                                                  │" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
        Write-Output "% └──────────────────────────────────────────────────────────────┘" | Out-file -FilePath $pdfFile -Encoding utf8 -Append

        $IssueAssigned = 0


        if ($events.Count -gt 0){
            WriteLatex "\subsubsection{Eventos}"
            $FechaCreado = Get-Date
            $FechaAsignado = Get-Date
            $FechaCerrado = Get-Date

            WriteLatex "\begin{tikzpicture}"
            WriteLatex "\matrix (first) [table,text width=17em]{"
            WriteLatex "			& Tipo evento & Información & Fecha \\"
            For ($k=0; $k -lt $events.Count; $k++) {
                #$line = ($k+1).ToString() + "&" + "\textbf{\textcolor{Blue4}{\faCheckSquareO}} "+ $events[$k].event + "&" 
                # segun el tipo de evento, armo la linea
                
                Switch ($events[$k].event){
                    "assigned" {
                        $line = "\textbf{\textcolor{SpringGreen4}{\faPlusSquare}} "+ "&" + $events[$k].event + "&"
                        $FechaAsignado = [datetime]$events[$k].created_at
                        #Write-Output $events[$k]
                        if ($events[$k].assignee.login -eq $events[$k].actor.login ){
                            $line = $line  + "Asignada a \textbf{\textcolor{Blue4}{" + $events[$k].assignee.login + "}} por si mismo&"
                        }
                        else{
                            $line = $line  + "Asignada a \textbf{\textcolor{Blue4}{" + $events[$k].assignee.login + "}} por \textbf{\textcolor{Blue4}{" + $events[$k].actor.login +"}}&"
                        }
                        $IssueAssigned = 1

                    }
                    "closed" {
                        #Write-Output $events[$k]
                        $line = "\textbf{\textcolor{SpringGreen4}{\faEnvelope}} "+ "&" + $events[$k].event + "&"
                        $FechaCerrado = [datetime]$events[$k].created_at
                        $line = $line  + "\textbf{\textcolor{Blue4}{" + $events[$k].actor.login +"}} cerró la tarea" + "&"
                    }
                    "cross-referenced"
                    {
                        $line = "\textbf{\textcolor{SpringGreen4}{\faExternalLink}} "+ "&" + $events[$k].event + "&"
                        $line = $line  + "se referencia a otra tarea" + "&"
                    }
                    "commented"
                    {
                        $line = "\textbf{\textcolor{SpringGreen4}{\faCommentO}} "+ "&" + $events[$k].event + "&" 
                        $line = $line  + "comentado por \textbf{\textcolor{Blue4}{" + $events[$k].user.login +"}}&"
                    }
                    "labeled"
                    {
                        $line = "\textbf{\textcolor{SpringGreen4}{\faEdit}} "+ "&" + $events[$k].event + "&"
                        $line = $line  + "\textbf{\textcolor{Blue4}{" + $events[$k].actor.login +"}} etiquetó " + "\textbf{\textcolor[HTML]{" + $events[$k].label.color +"}{\faCheckCircle} " + $events[$k].label.name +"}&"
                    }
                    "unassigned"
                    {
                        $line = "\textbf{\textcolor{SpringGreen4}{\faMinusSquare}} "+ "&" + $events[$k].event + "&"
                        $line = $line  + "Des-asignado por \textbf{\textcolor{Blue4}{" + $events[$k].actor.login +"}}&"
                        $IssueAssigned = 0
                    }
                    "renamed"
                    {
                        $line = "\textbf{\textcolor{SpringGreen4}{\faEdit}} "+ "&" + $events[$k].event + "&"
                        $line = $line  + "\textbf{\textcolor{Blue4}{" + $events[$k].actor.login +"}} cambió el título&"
                    }
                    default {
                        $line = "\textbf{\textcolor{lightgray}{?}} "+ "&" + $events[$k].event + "&"
                        $line = $line  + " - " + "&"
                    }
                }
                $line = $line  + ([datetime]$events[$k].created_at).ToString('dd/MM/yyyy HH:mm') + "\\"
                WriteLatex $line
            }

            
            if ($state -eq "closed"){

                $diferencia = $FechaCerrado  - $FechaAsignado
                $TotalHours = $TotalHours + $($diferencia.TotalHours)

                Write-Host ">"
                Write-Host $issues[$i].title
                Write-Host $FechaCerrado
                Write-Host $FechaAsignado
                Write-Host $diferencia
                Write-Host $diferencia.TotalHours
                Write-Host "<"

                if ($diferencia.TotalHours -lt 0){
                    if ($IssueAssigned -eq 0){
                        $line = "" + "&" +
                                "" + "&" +
                                "\textcolor{teal}{\textbf{TIEMPO TOTAL}}" + "& \textcolor{Red1}{" + 
                                " SIN ASIGNAR " + " horas \faExclamationTriangle } \ \\"
                    
                    }
                    else{

                    $line = "" + "&" +
                            "" + "&" +
                            "\textcolor{teal}{\textbf{TIEMPO TOTAL}}" + "& \textcolor{Red1}{" + 
                            [math]::Round($($diferencia.TotalHours),2) + " horas \faExclamationTriangle } \ \\"
                    }
                }
                else 
                {
                    if ($diferencia.TotalHours -lt 1){
                    
                        $line = "" + "&" +
                            "" + "&" +
                            "\textcolor{teal}{\textbf{TIEMPO TOTAL}}" + "&" + 
                            [math]::Round($($diferencia.TotalMinutes),2) + " minutos \\"

                    }
                    else
                    {
                    if ($diferencia.TotalHours -gt 24){
                        $line = "" + "&" +
                                "" + "&" +
                                "\textcolor{teal}{\textbf{TIEMPO TOTAL}}" + "&" + 
                               [math]::Round($($diferencia.TotalDays),2) + " dias \\"
                    }
                    else
                    {
                        $line = "" + "&" +
                                "" + "&" +
                                "\textcolor{teal}{\textbf{TIEMPO TOTAL}}" + "&" + 
                               [math]::Round($($diferencia.TotalHours),2) + " horas \\"
                     }   }
                    
                }
                if ($IssueAssigned -eq 1){
                    $TaskArray.Add($issues[$i].number.ToString() + " : " + $issues[$i].title)
                    $TimeArray.Add([math]::Round($($diferencia.TotalDays),2))
                    $DateCloseArray.Add($FechaCerrado)
                }
                WriteLatex $line
            }
            WriteLatex "};"
            WriteLatex "\end{tikzpicture}"
        }

        Write-Output "% ┌──────────────────────────────────────────────────────────────┐" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
        Write-Output "% │ a.2. Comments                                                │" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
        Write-Output "% └──────────────────────────────────────────────────────────────┘" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
        $comments = Invoke-RestMethod -Method get -Uri $issues[$i].comments_url -Headers $headers 
        #Write-Output $comments
    
        if ($comments.Count -gt 0){
            WriteLatex "\subsubsection{Comentarios}"
            For ($j=0; $j -lt $comments.Count; $j++) {

                    $line = "\begin{tcolorbox}["
	                WriteLatex $line
                    $line = "    colback=Snow2,"
	                WriteLatex $line
                    $line = "    colframe=DeepSkyBlue3,"
                    WriteLatex $line
	                $line = "    title=My nice heading,"
                    WriteLatex $line
	                $line = "    title=" + ([datetime]$comments[$j].created_at).ToString('dd/MM/yyyy HH:mm') + " by " + $comments[$j].user.login + "]"
                    WriteLatex $line
	                $line = $comments[$j].body
                    WriteLatex $line
                    $line = "\end{tcolorbox}"                     
                    WriteLatex $line

            }
        }
    $line = "\newpage"
    WriteLatex $line
    }
    #

    if ($state -eq "closed"){
        WriteSubSectionLatex "Tiempo promedio de resolución"       

        $line = "\par \textbf{Total de casos}: " + $issues.Count
        WriteLatex $line
        $line = "\par \textbf{Total de horas en resolverlos}: \Large " + [math]::Round($TotalHours,2) + " \normalsize horas"
        WriteLatex $line
        $TTLAvg = $TotalHours / $issues.Count 
        $line = "\par \textbf{Promedio}: \Large " + [math]::Round($TTLAvg,2) + " \normalsize horas/caso"
        WriteLatex $line
    }
 

}

##### Main function 
Write-Output "% ┌──────────────────────────────────────────────────────────────┐" | Out-file -FilePath $pdfFile -Encoding utf8
Write-Output "% │Generate.ps1 generó automáticamente este archivo              │" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% │   Este script ingresa a un repositorio de GitHub, itera      │" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% │en los issues, los lista, por su estado ( abiertos,           │" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% │cerrados ), muestra sus timelines y eventos                   │" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% └──────────────────────────────────────────────────────────────┘" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "\documentclass[]{article}"                                          | Out-file -FilePath $pdfFile -Encoding utf8 -Append

Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% ┌──────────────────────────────────────────────────────────────┐" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% │Packages, commands, defs, etc                                 │" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% └──────────────────────────────────────────────────────────────┘" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append

WriteLatexPreamble

Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% ┌──────────────────────────────────────────────────────────────┐" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% │ Inicio del documento                                         │" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% └──────────────────────────────────────────────────────────────┘" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "\begin{document}"                                                   | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "\tableofcontents"                                                   | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "\newpage"                                                           | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% ┌──────────────────────────────────────────────────────────────┐" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% │ Tickets abiertos                                             │" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% └──────────────────────────────────────────────────────────────┘" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append

WriteSectionLatex "Tickets abiertos"
GetIssues "open"

Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% ┌──────────────────────────────────────────────────────────────┐" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% │ Tickets cerrados                                             │" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% └──────────────────────────────────────────────────────────────┘" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append

WriteSectionLatex "Tickets cerrados"
GetIssues "closed"

Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% ┌──────────────────────────────────────────────────────────────┐" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% │ Gráfico                                                      │" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output "% └──────────────────────────────────────────────────────────────┘" | Out-file -FilePath $pdfFile -Encoding utf8 -Append
Write-Output " "                                                                  | Out-file -FilePath $pdfFile -Encoding utf8 -Append


WriteSectionLatex "Gráfico de rendimiento"
DrawGraph

WriteLatex "\end{document}"


#cd $pdfPath 
#pdflatex.exe $pdfFile
#pdflatex.exe $pdfFile
#cd ..