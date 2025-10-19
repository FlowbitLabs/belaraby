# How to reset all commits

```bash
# 1. Make sure you’re on the dev branch
git checkout dev

# 2. Create a new orphan branch with no history
git checkout --orphan temp_branch

# 3. Add all current files to the new branch
git add -A

# 4. Make a new initial commit
git commit -m "Initial commit"

# 5. Delete the old dev branch
git branch -D dev

# 6. Rename the temp branch to dev
git branch -m dev

# 7. Force push to remote dev, replacing old history
git push -f origin dev
```
