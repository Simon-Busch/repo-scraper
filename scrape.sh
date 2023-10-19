# Set your GitHub organization and folder name
ORG_NAME="github_org"
FOLDER_NAME="public-repos"

# Create the folder
mkdir -p "$FOLDER_NAME"

# Initialize variables
PAGE=1
REPO_LIST=()

# Fetch the list of public repositories in the organization
while true; do
  PAGE_REPOS=$(curl -s "https://api.github.com/orgs/$ORG_NAME/repos?per_page=100&page=$PAGE" | jq -r '.[].html_url')
  if [ -z "$PAGE_REPOS" ]; then
    break
  fi
  REPO_LIST=("${REPO_LIST[@]}" $PAGE_REPOS)
  PAGE=$((PAGE + 1))
done

# Clone each repository into the "Data" folder
for repo in "${REPO_LIST[@]}"
do
    REPO_NAME=$(basename $repo)
    REPO_URL="https://github.com/$ORG_NAME/$REPO_NAME.git"
    git clone "$REPO_URL" "$FOLDER_NAME/$REPO_NAME"
done
