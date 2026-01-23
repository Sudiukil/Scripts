# Script to list git tags in semver order, with support for RC (Release Candidate)
# RC versions are listed logically, before the corresponding versions (e.g. v1.2.3-rc1 before v1.2.3)

# Define a Semantic Versioning class
class SemanticVersion {
  [string]$Tag      # Full tag string (e.g., v1.2.3-rc1)
  [int]$Major       # Major version
  [int]$Minor       # Minor version
  [int]$Patch       # Patch version
  [int]$Rc    # RC number (e.g., 1 for -rc1)

  # Constructor to parse and initialize a new instance
  SemanticVersion([string]$tag) {
    $this.Tag = $tag
    $regex = '^v(\d+)\.(\d+)\.(\d+)(-rc(\d+))?$'

    # Parse the semantic version components using regex
    if ($tag -match $regex) {
      $this.Major = [int]$matches[1]
      $this.Minor = [int]$matches[2]
      $this.Patch = [int]$matches[3]
      $this.Rc = if ($matches[5]) { [int]$matches[5] } else { 99 } # This is the (quick and dirty) secret sauce
    }
    else {
      throw "Invalid semantic version tag format: $tag"
    }
  }
}

# Function to parse and sort tags by semantic versioning
function Sort-GitTagsBySemVer {
  # Retrieve all Git tags
  $rawTags = git tag | ForEach-Object { $_.Trim() }

  # Create an array to hold SemanticVersion instances
  $validTags = @()
  $invalidTags = @()

  # Validate and add tags as SemanticVersion objects
  foreach ($tag in $rawTags) {
    try {
      $validTags += [SemanticVersion]::New($tag)
    }
    catch {
      $invalidTags += $tag
    }
  }

  # Sort tags
  $sortedTags = $validTags | Sort-Object Major, Minor, Patch, Rc

  # Output sorted tags
  foreach ($version in $sortedTags) {
    Write-Output $version.Tag
  }

  if ($invalidTags.Length -gt 0) {
    Write-Host -ForegroundColor Gray "Ignored invalid semver tags: $($invalidTag -join ', ')"
  }
}

# Run the function
Sort-GitTagsBySemVer
