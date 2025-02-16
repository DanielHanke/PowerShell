
 param (
    [string]$Name = "article"
 )





$pdfFile = $PSScriptRoot +  "\" + $Name + ".tex" 

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
                $outputFile = $pdfPath +"\img\" + $global:img_num.ToString() + ".jpg"
                $img = Invoke-RestMethod -Method get -Uri $line.substring( $startImageUri, $endImageUri) -Headers $headers -OutFile $outputFile
                $str = "\includegraphics[width=\textwidth]{./img/" + + $img_num.ToString() + ".jpg" + "}"
                $line = $line.replace( $line.substring( $startImageUri-9, $endImageUri+10), $str) 
                $global:img_num = $global:img_num + 1
            }        
        }
        Write-Output $line.replace("_","\textunderscore ").replace("#","\# ").replace(">"," ")  | Out-file -FilePath $pdfFile -Encoding utf8 -Append
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

function LATEX_WriteComment{
    param ($line)
    
    if ($line){
        Write-Output " " | Out-file -FilePath $pdfFile -Encoding utf8 -Append
        Write-Output "% " | Out-file -FilePath $pdfFile -Encoding utf8 -Append
        $line = "% " + $line
        Write-Output $line | Out-file -FilePath $pdfFile -Encoding utf8 -Append
        Write-Output "% " | Out-file -FilePath $pdfFile -Encoding utf8 -Append    
        Write-Output " " | Out-file -FilePath $pdfFile -Encoding utf8 -Append
    }
}


function LATEX_WriteParagraph{
    param ($line)
    
    if ($line){
        $line = "\par " + $line
        Write-Output $line | Out-file -FilePath $pdfFile -Encoding utf8 -Append
    }
}


##### Main function 


                                        

Write-Output " " | Out-file -FilePath $pdfFile -Encoding utf8

LATEX_WriteComment "This document is automatically generated by powershell"
LATEX_Write "\documentclass[]{article}"
LATEX_WriteComment "Packages, commands, and other stuff..."

WriteLatexPreamble

LATEX_Write "\begin{document}"

WriteSectionLatex "hi!"

LATEX_WriteParagraph "Say something!!!"
LATEX_WriteParagraph "Something new!\\like anyone likes!"

LATEX_Write "\end{document}"

Write-Output $pdfFile
cd $PSScriptRoot

pdflatex.exe $pdfFile


