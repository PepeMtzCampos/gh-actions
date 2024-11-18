# Define the repositories and environments
$REPOS = @("PepeMtzCampos/gh-actions", "PepeMtzCampos/gh-executionflow", "PepeMtzCampos/gh-events", "PepeMtzCampos/gh-first-action")
$API_HEADER_VERSION = "X-GitHub-Api-Version: 2022-11-28"
$API_HEADER_FORMAT = "Accept: application/vnd.github+json"

foreach ($REPO in $REPOS) {

  Write-Output ""
  # Verify access to the repository by listing the workflow permissions
    try {
        Write-Output "Verifying access to repository $REPO by listing the workflow permissions"
        
        $permissions = gh api -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "/repos/$REPO/actions/permissions/workflow" | ConvertFrom-Json
        Write-Output "Workflow permissions in ${REPO}:"
        $permissions | ForEach-Object { Write-Output "$($_.name): $($_.value)" }
    } catch {
        Write-Output "Failed to access workflow permissions in repository $REPO"
    }
   # Check the permissions of the GitHub token
    try {
        Write-Output "Checking the permissions of the GitHub token"
        $tokenInfo = gh api -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "/user" -i
        $scopes = ($tokenInfo -split "`n" | Where-Object { $_ -match "^x-oauth-scopes:" }) -replace "^x-oauth-scopes: ", ""
        Write-Output "Token permissions (scopes): $scopes"
    } catch {
        Write-Output "Failed to check the permissions of the GitHub token"
    }
}