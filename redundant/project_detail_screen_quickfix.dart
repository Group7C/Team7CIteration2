// Replace these two lines in your project_detail_screen.dart:

// CURRENT (WRONG):
projectId: widget.projectName.replaceAll(' ', '').toLowerCase(),

// REPLACE WITH (CORRECT):
projectId: widget.projectId,

// AND ALSO:

// CURRENT (WRONG):
ProjectKanban(
  projectId: widget.projectName.replaceAll(' ', '').toLowerCase(),
  ...
)

// REPLACE WITH (CORRECT):
ProjectKanban(
  projectId: widget.projectId,
  ...
)
