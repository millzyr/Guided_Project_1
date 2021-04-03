# github_script.R - Creates a link between Rstudio, git and github.

# Install libraries
install.packages("usethis")
install.packages("gitcreds")

# Create a PAT
usethis::create_github_token()

# Setup credentials in Windows Credentials Manager
gitcreds::gitcreds_set()

# Set your email
email_address <- ''
# Set your username
user_name <- ''

# Run system commands to setup authentication
system(paste0('git config --global user.email ',email_address))
system(paste0('git config --global user.name ',user_name))