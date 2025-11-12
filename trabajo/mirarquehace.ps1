# CONFIGURACIÓN
$repo = "RepoTRND/PatternPipe"
$title = "02-01.Relevar API"
$body = ""
$label = "refactoring"

# 1. Crear el issue y obtener su node_id
$issueJson = gh issue create --repo $repo --title $title --body $body --label $label --json id,title
$issueNodeId = ($issueJson | ConvertFrom-Json).id
Write-Host "Issue creado con node_id: $issueNodeId"

# 2. Obtener el project_id del proyecto v2
$projectQuery = @'
{
  organization(login: "RepoTRND") {
    projectsV2(first: 10) {
      nodes {
        id
        title
      }
    }
  }
}
'@

$projectResponse = gh api graphql -f query=$projectQuery
$projects = ($projectResponse | ConvertFrom-Json).organization.projectsV2.nodes

# Mostrar lista de proyectos
Write-Host "`nProyectos encontrados:"
$projects | ForEach-Object { Write-Host "$($_.title): $($_.id)" }

# Seleccionar el proyecto manualmente (o automatizar si ya sabés el nombre)
$projectId = Read-Host "`nPegá el project_id al que querés asignar el issue"

# 3. Agregar el issue al proyecto
$mutation = @"
mutation {
  addProjectV2ItemById(input: {projectId: ""$projectId"", contentId: ""$issueNodeId""}) {
    item {
      id
    }
  }
}
"@

$addResponse = gh api graphql -f query=$mutation
Write-Host "`nIssue asignado al proyecto correctamente."
