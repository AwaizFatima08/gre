#!/usr/bin/env bash
# Pushes website/ to the `deploy` branch. Hostinger's Git deployment for gre.homilabs.org pulls that
# branch into the subdomain's web root. Afterwards flush the CDN cache in hPanel if pages look stale.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ -n "$(git status --porcelain -- website)" ]; then
  echo "website/ has uncommitted changes: commit them first, then rerun."
  exit 1
fi
SPLIT="$(git subtree split --prefix website HEAD)"
git push --force origin "$SPLIT:refs/heads/deploy"
echo "Pushed website/ ($SPLIT) to the deploy branch."
