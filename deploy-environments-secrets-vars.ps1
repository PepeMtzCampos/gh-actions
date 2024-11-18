# Define the repositories and environments
$REPOS = @("PepeMtzCampos/gh-actions", "PepeMtzCampos/gh-executionflow", "PepeMtzCampos/gh-events", "PepeMtzCampos/gh-first-action")
$ENVIRONMENTS = @("dev", "test", "prod")

# Define repository-level variables
$REPO_VARS = @{
  "CODE_VERSION" = "1.8.0.x"
  "ARTIFACTORY_URL" = "artifactory.pm.com"
}

# Define environment variables and secrets for each environment
$ENV_VARS = @{
  "dev" = @{
    "ARTIFACT_FOLDER" = "tfs-builds/mfgmes/jarvis_185987/"
    "IMAGE_FOLDER" = "docker-int-snapshot/mfg/jarvis_185987/"
    "NAMESPACE" = "185987-dev"
  }
  "test" = @{
    "ARTIFACT_FOLDER" = "tfs-releases/mfgmes/jarvis_185987/"
    "IMAGE_FOLDER" = "docker-int-release/mfg/jarvis_185987/"
    "NAMESPACE" = "185987-test"
  }
  "prod" = @{
    "ARTIFACT_FOLDER" = "tfs-releases/mfgmes/jarvis_185987/"
    "IMAGE_FOLDER" = "docker-int-release/mfg/jarvis_185987/"
    "NAMESPACE" = "185987-prod"
  }
}

# KUBE_CONFIG are secrets in this repository
$SECRETS = @{
  "dev" = @{
    "KUBE_CONFIG" = $env:DEV_KUBE_CONFIG
  }
  "test" = @{
    "KUBE_CONFIG" = $env:TEST_KUBE_CONFIG
  }
  "prod" = @{
    "MI_KUBE_CONFIG" = $env:PROD_MI_KUBE_CONFIG
	"WA_KUBE_CONFIG" = $env:PROD_WA_KUBE_CONFIG
  }
}

$API_HEADER_VERSION = "X-GitHub-Api-Version: 2022-11-28"
$API_HEADER_FORMAT = "Accept: application/vnd.github+json"

foreach ($REPO in $REPOS) {

  # Extract FOLDER_SUFFIX from repository name
  $FOLDER_SUFFIX = $REPO -replace 'PepeMtzCampos/gh-', ''

  Write-Output ""
  # Set or update repository-level variables
  foreach ($name in $REPO_VARS.Keys) {
    $value = $REPO_VARS[$name]
    try {
      Write-Output "Checking if variable $name exists in repository $REPO"
      $existingVar = gh api -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "repos/$REPO/actions/variables/$name" | ConvertFrom-Json
      if ($existingVar -and $existingVar.value -ne $value) {
        Write-Output "Updating variable $name with value $value in repository $REPO"
        gh api -X PATCH -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "repos/$REPO/actions/variables/$name" -f value="$value"
      } elseif (-not $existingVar) {
        Write-Output "Setting variable $name with value $value in repository $REPO"
        gh api -X POST -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "repos/$REPO/actions/variables" -f name="$name" -f value="$value"
      }
    } catch {
      Write-Output "Failed to check or set variable $name in repository $REPO"
    }
  }

  Write-Output ""
  # Set or update FOLDER_SUFFIX variable
  try {
    Write-Output "Checking if variable FOLDER_SUFFIX exists in repository $REPO"
    $existingVar = gh api -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "repos/$REPO/actions/variables/FOLDER_SUFFIX" | ConvertFrom-Json
    if ($existingVar -and $existingVar.value -ne $FOLDER_SUFFIX) {
      Write-Output "Updating variable FOLDER_SUFFIX with value $FOLDER_SUFFIX in repository $REPO"
      gh api -X PATCH -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "repos/$REPO/actions/variables/FOLDER_SUFFIX" -f value="$FOLDER_SUFFIX"
    } elseif (-not $existingVar) {
      Write-Output "Setting variable FOLDER_SUFFIX with value $FOLDER_SUFFIX in repository $REPO"
      gh api -X POST -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "repos/$REPO/actions/variables" -f name="FOLDER_SUFFIX" -f value="$FOLDER_SUFFIX"
    }
  } catch {
    Write-Output "Failed to check or set variable FOLDER_SUFFIX in repository $REPO"
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
    # Set or update environmental variables
    foreach ($name in $ENV_VARS[$ENVIRONMENT].Keys) {
      $value = $ENV_VARS[$ENVIRONMENT][$name]
      try {
        Write-Output "Checking if variable $name exists in environment $ENVIRONMENT of repository $REPO"
        $existingVar = gh api -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "repos/$REPO/environments/$ENVIRONMENT/variables/$name" | ConvertFrom-Json
        if ($existingVar -and $existingVar.value -ne $value) {
          Write-Output "Updating variable $name with value $value in environment $ENVIRONMENT of repository $REPO"
          gh api -X PATCH -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "repos/$REPO/environments/$ENVIRONMENT/variables/$name" -f value="$value"
        } elseif (-not $existingVar) {
          Write-Output "Setting variable $name with value $value in environment $ENVIRONMENT of repository $REPO"
          gh api -X POST -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "repos/$REPO/environments/$ENVIRONMENT/variables" -f name="$name" -f value="$value"
        }
      } catch {
        Write-Output "Failed to check or set variable $name in environment $ENVIRONMENT of repository $REPO"
      }
    }


    Write-Output ""
    # Set or update environmental secrets
    foreach ($name in $SECRETS[$ENVIRONMENT].Keys) {
      $value = $SECRETS[$ENVIRONMENT][$name]
      try {
        Write-Output "Checking if secret $name exists in environment $ENVIRONMENT of repository $REPO"
        $existingSecret = gh api -H ${API_HEADER_FORMAT} -H ${API_HEADER_VERSION} "repos/$REPO/environments/$ENVIRONMENT/secrets/$name" | ConvertFrom-Json
        if ($existingSecret -and $existingSecret.value -ne $value) {
          Write-Output "Updating secret $name in environment $ENVIRONMENT of repository $REPO"
          $value | gh secret set $name --repo $REPO --env $ENVIRONMENT --update
        } elseif (-not $existingSecret) {
          Write-Output "Setting secret $name in environment $ENVIRONMENT of repository $REPO"
          $value | gh secret set $name --repo $REPO --env $ENVIRONMENT
        }
      } catch {
        Write-Output "Failed to check or set secret $name in environment $ENVIRONMENT of repository $REPO"
      }
    }
  }
}