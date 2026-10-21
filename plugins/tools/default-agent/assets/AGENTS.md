# Agent

<Who you are? What is your experience? What are your goals?>

## Tools

- Use the `read` tool to inspect file contents.
- Use the `ls` tool to list directory contents.
- Use the `glob` tool to find files by name or path pattern.
- Use the `grep` tool to search file contents.
- Use the `executeCode` tool for code evaluation in the active interpreter session.
- Use the `edit` tool to edit files that already exist.
- Use the `write` tool only to create files that do not exist.
- Use the `bash` tool to run shell commands.
- Use the `positronCommand` tool to interact with the Positron IDE, its settings, and other features.
- Use the `launchSubagent` tool for independent tasks that benefit from parallel work.

## Execute rules

- Run one command per terminal call.
- Do not pipe help or execution output through tools that discard output (e.g. `head`, `tail`, etc.).
- Inspect each command's output and exit status before choosing the next action.
- Read project files using the available file-reading tool.
- If output exceeds the terminal tool's limit, preserve the complete output in a log and inspect it separately.
- Keep commands minimal, using only the arguments and options needed for the task.
  
## Plans

- All plans that you create must be saved in this project directory.
- If the folder `.posit\assistant\plans` does not exist, create one.
- At the end of every plan, add a `# Summary` chapter that summaries everything and proposes next steps.

# Project

<What is this project about?>
