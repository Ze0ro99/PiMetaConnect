import requests
import time

GITHUB_TOKEN = "your_token_here"
REPO_OWNER = "Ze0ro99"
REPO_NAME = "PiMetaConnect"
HEADERS = {'Authorization': f'token {GITHUB_TOKEN}'}

def get_failed_workflows():
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/actions/runs"
    response = requests.get(url, headers=HEADERS)
    response.raise_for_status()
    runs = response.json()["workflow_runs"]
    return [run for run in runs if run["conclusion"] == "failure"]

def retry_workflow(run_id):
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/actions/runs/{run_id}/rerun"
    response = requests.post(url, headers=HEADERS)
    if response.status_code == 201:
        print(f"Workflow {run_id} restarted successfully.")
    else:
        print(f"Failed to restart workflow {run_id}: {response.json()}")

def main():
    while True:
        print("Checking for failed workflows...")
        failed_workflows = get_failed_workflows()
        for workflow in failed_workflows:
            print(f"Retrying workflow: {workflow['name']} (ID: {workflow['id']})")
            retry_workflow(workflow["id"])
        print("Waiting before the next check...")
        time.sleep(3600)  # Check every hour

if __name__ == "__main__":
    main()
