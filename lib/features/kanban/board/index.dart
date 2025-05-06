// Kanban exports [one-stop import for all kanban stuff]

// Core widgets [board, columns, cards]
export 'components/kanban_board.dart';
export 'components/kanban_column.dart';
export 'components/task_card.dart';

// Container components [connect to data]
export 'containers/project_kanban.dart';
export 'containers/user_kanban.dart';

// Data models [task structure]
export 'models/kanban_task.dart';

// Helper functions [drag/drop logic]
export 'utils/task_converter.dart';
export 'utils/drag_drop_handler.dart';

// Mock data
export 'mock_data/mock_tasks.dart';