# Define the repositories and environments
$REPOS = @("PepeMtzCampos/gh-actions", "PepeMtzCampos/gh-executionflow", "PepeMtzCampos/gh-events", "PepeMtzCampos/gh-first-action")
$ENVIRONMENTS = @("dev", "test", "prod")
$API_HEADER_VERSION = "X-GitHub-Api-Version: 2022-11-28"
$API_HEADER_FORMAT = "Accept: application/vnd.github+json"

foreach ($REPO in $REPOS) {

  Write-Output ""
   # Check the permissions of the GitHub token
    try {
        Write-Output "Checking the permissions of the GitHub token"
        $tokenInfo = gh api -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "/user" -i
        $scopes = ($tokenInfo -split "`n" | Where-Object { $_ -match "^x-oauth-scopes:" }) -replace "^x-oauth-scopes: ", ""
        Write-Output "Token permissions (scopes): $scopes"
    } catch {
        Write-Output "Failed to check the permissions of the GitHub token"
    }

    Write-Output ""
    # Verify access to the repository by listing the repository variables
    try {
        Write-Output "Verifying access to repository ${REPO} by listing the repository variables"
        $variables = gh api -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "/repos/${REPO}/actions/variables" | ConvertFrom-Json
        Write-Output "Repository variables in ${REPO}:"
        $variables.variables | ForEach-Object { Write-Output "$($_.name): $($_.value)" }
      } catch {
        Write-Output "Failed to access repository ${REPO}"
      }

      Write-Output ""
      # Verify access to the repository by listing the environments
        try {
            Write-Output "Verifying access to repository $REPO by listing the environments"
            $response = gh api -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "/repos/$REPO/environments" | ConvertFrom-Json
            Write-Output "Environments in ${REPO}:"
            $response.environments | ForEach-Object { Write-Output "$($_.name)" }
        } catch {
            Write-Output "Failed to access repository $REPO"
        }

      foreach ($ENVIRONMENT in $ENVIRONMENTS) {
    
        Write-Output ""
        # Verify access to the repository by listing the environment variables
        try {
          Write-Output "Verifying access to repository $REPO environment $ENVIRONMENT by listing the environment variables"
          $envVars = gh api -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "/repos/$REPO/environments/$ENVIRONMENT/variables" | ConvertFrom-Json
          Write-Output "Environment variables in $REPO environment ${ENVIRONMENT}:"
          $envVars.variables | ForEach-Object { Write-Output "$($_.name): $($_.value)" }
        } catch {
          Write-Output "Failed to access environment variables in repository $REPO environment $ENVIRONMENT"
        }
    
        Write-Output ""
        # Verify access to the repository by listing the environment secrets
        try {
            Write-Output "Verifying access to repository $REPO environment $ENVIRONMENT by listing the environment secrets"
            $envSecrets = gh api -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "/repos/$REPO/environments/$ENVIRONMENT/secrets" | ConvertFrom-Json
            Write-Output "Environment secrets in $REPO environment ${ENVIRONMENT}:"
            $envSecrets.secrets | ForEach-Object { Write-Output "$($_.name)" }
        } catch {
            Write-Output "Failed to access environment secrets in repository $REPO environment $ENVIRONMENT"
        }
      }
}