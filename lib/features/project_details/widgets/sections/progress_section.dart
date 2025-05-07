import 'package:flutter/material.dart';
import '../../models/project_details_view_model.dart';
import '../../utils/progress_calculator.dart';
import '../../../../features/common/widgets/section_card.dart';
import '../../../../features/common/widgets/action_button.dart';

class ProgressSection extends StatefulWidget {
  final ProjectDetailsViewModel viewModel;
  final VoidCallback onGenerateReport;
  final ValueNotifier<bool> refreshTrigger;
  
  const ProgressSection({
    Key? key,
    required this.viewModel,
    required this.onGenerateReport,
    required this.refreshTrigger,
  }) : super(key: key);

  @override
  State<ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<ProgressSection> {
  double _progress = 0.0;
  int _completedTasks = 0;
  int _totalTasks = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Initial calculation
    _calculateProgress();
    
    // Listen for refresh events
    widget.refreshTrigger.addListener(_onRefreshTriggered);
  }
  
  @override
  void didUpdateWidget(ProgressSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update listener if the refresh trigger changes
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      oldWidget.refreshTrigger.removeListener(_onRefreshTriggered);
      widget.refreshTrigger.addListener(_onRefreshTriggered);
    }
    
    // Recalculate whenever the view model changes
    _calculateProgress();
  }
  
  void _onRefreshTriggered() {
    if (widget.refreshTrigger.value) {
      // Reset the trigger
      widget.refreshTrigger.value = false;
      
      // Force update the progress
      if (mounted) {
        setState(() {
          _calculateProgress();
        });
      }
    }
  }
  
  // Calculate progress directly from database
  void _calculateProgress() {
    // Use the ViewModel's getter methods, but perform calculation in this widget
    _completedTasks = widget.viewModel.completedTasks;
    _totalTasks = widget.viewModel.totalTasks;
    
    // Calculate progress
    if (_totalTasks > 0) {
      _progress = _completedTasks / _totalTasks;
    } else {
      _progress = 0.0;
    }
  }
  
  @override
  void dispose() {
    widget.refreshTrigger.removeListener(_onRefreshTriggered);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Progress',
      height: 220,
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Completion',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(ProgressCalculator.getProgressColor(_progress)),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                  ),
                ),
                const Spacer(),
                Text(
                  'Complete (${_completedTasks}/${_totalTasks} tasks)',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ActionButton(
                label: 'Generate Report',
                icon: Icons.description,
                onPressed: widget.onGenerateReport,
                backgroundColor: const Color(0xFF1DB954), // Teal color
                scale: 0.9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}