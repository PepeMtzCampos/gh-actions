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
}