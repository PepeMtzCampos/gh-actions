# Define the repositories and environments
$REPOS = @("PepeMtzCampos/gh-executionflow", "PepeMtzCampos/gh-events", "PepeMtzCampos/gh-first-action")
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

foreach ($REPO in $REPOS) {
  # Extract FOLDER_SUFFIX from repository name
  $FOLDER_SUFFIX = $REPO -replace 'PepeMtzCampos/gh-', ''

  # Set or update repository-level variables
  foreach ($name in $REPO_VARS.Keys) {
    $value = $REPO_VARS[$name]
    try {
      Write-Output "Setting variable $name with value $value in repository $REPO"
      gh api -X POST "repos/$REPO/variables" -f name="$name" -f value="$value"
    } catch {
      Write-Output "Updating variable $name with value $value in repository $REPO"
      gh api -X PATCH "repos/$REPO/variables/$name" -f value="$value"
    }
  }

  # Set or update FOLDER_SUFFIX variable
  try {
    Write-Output "Setting variable FOLDER_SUFFIX with value $FOLDER_SUFFIX in repository $REPO"
    gh api -X POST "repos/$REPO/variables" -f name="FOLDER_SUFFIX" -f value="$FOLDER_SUFFIX"
  } catch {
    Write-Output "Updating variable FOLDER_SUFFIX with value $FOLDER_SUFFIX in repository $REPO"
    gh api -X PATCH "repos/$REPO/variables/FOLDER_SUFFIX" -f value="$FOLDER_SUFFIX"
  }

  foreach ($ENVIRONMENT in $ENVIRONMENTS) {
    # Create environment if it doesn't exist
    try {
      Write-Output "Create environment $ENVIRONMENT if it doesn't exist"
      gh api -X POST "repos/$REPO/environments/$ENVIRONMENT"
    } catch {
      Write-Output "Environment $ENVIRONMENT already exists in $REPO"
    }

    # Set or update environment variables
    foreach ($name in $ENV_VARS[$ENVIRONMENT].Keys) {
      $value = $ENV_VARS[$ENVIRONMENT][$name]
      try {
        Write-Output "Setting variable $name with value $value in repository $REPO"
        gh api -X POST "repos/$REPO/environments/$ENVIRONMENT/variables" -f name="$name" -f value="$value"
      } catch {
        Write-Output "Updating variable $name with value $value in repository $REPO"
        gh api -X PATCH "repos/$REPO/environments/$ENVIRONMENT/variables/$name" -f value="$value"
      }
    }

    # Set or update secrets
    foreach ($name in $SECRETS[$ENVIRONMENT].Keys) {
      $value = $SECRETS[$ENVIRONMENT][$name]
      try {
        Write-Output "Setting secret $name in repository $REPO environment $ENVIRONMENT"
        $value | gh secret set $name --repo $REPO --env $ENVIRONMENT
      } catch {
        Write-Output "Updating secret $name in repository $REPO environment $ENVIRONMENT"
        $value | gh secret set $name --repo $REPO --env $ENVIRONMENT --update
      }
    }
  }
}