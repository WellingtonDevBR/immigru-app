import 'package:flutter/material.dart';

/// A modern, customizable date picker that allows selecting month and year
class EnhancedDatePicker extends StatefulWidget {
  /// Initial date to display in the picker
  final DateTime? initialDate;
  
  /// Called when a date is selected
  final Function(DateTime) onDateSelected;
  
  /// Minimum selectable date
  final DateTime? firstDate;
  
  /// Maximum selectable date
  final DateTime? lastDate;

  const EnhancedDatePicker({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
  });

  /// Shows the date picker as a dialog
  static Future<DateTime?> showPicker(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          child: EnhancedDatePicker(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            onDateSelected: (date) {
              Navigator.of(context).pop(date);
            },
          ),
        );
      },
    );
  }

  @override
  State<EnhancedDatePicker> createState() => _EnhancedDatePickerState();
}

class _EnhancedDatePickerState extends State<EnhancedDatePicker> {
  late DateTime _currentDisplayedMonth;
  DateTime? _selectedDate;
  
  // Month names for dropdown
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _currentDisplayedMonth = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = Theme.of(context).colorScheme.secondary;
    
    // Modern color palette
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3142);
    final headerColor = isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF7F7F9);
    final selectedColor = primaryColor;
    final todayColor = accentColor;
    final dropdownBgColor = isDarkMode ? const Color(0xFF3D3D3D) : primaryColor.withValues(alpha: 0.08);
    final borderColor = isDarkMode ? const Color(0xFF3D3D3D) : const Color(0xFFEAEAEF);
    
    // Calculate valid year range for the dropdown
    final int minYear = widget.firstDate?.year ?? 1900;
    final int maxYear = widget.lastDate?.year ?? DateTime.now().year + 10;
    final List<int> years = List.generate(
      maxYear - minYear + 1, 
      (index) => minYear + index
    );
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Calendar header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: headerColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Month and Year selectors side by side
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous button
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: textColor, size: 28),
                      onPressed: () {
                        setState(() {
                          _currentDisplayedMonth = DateTime(
                            _currentDisplayedMonth.year,
                            _currentDisplayedMonth.month - 1,
                          );
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Month dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: dropdownBgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _currentDisplayedMonth.month,
                                isDense: true,
                                icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                onChanged: (int? value) {
                                  if (value != null) {
                                    setState(() {
                                      _currentDisplayedMonth = DateTime(
                                        _currentDisplayedMonth.year,
                                        value,
                                        1,
                                      );
                                    });
                                  }
                                },
                                items: List.generate(12, (index) {
                                  return DropdownMenuItem<int>(
                                    value: index + 1,
                                    child: Text(_months[index]),
                                  );
                                }),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Year dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: dropdownBgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _currentDisplayedMonth.year,
                                isDense: true,
                                icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor, // Make consistent with month dropdown
                                ),
                                onChanged: (int? value) {
                                  if (value != null) {
                                    setState(() {
                                      _currentDisplayedMonth = DateTime(
                                        value,
                                        _currentDisplayedMonth.month,
                                        1,
                                      );
                                    });
                                  }
                                },
                                items: years.map((int year) {
                                  return DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Next button
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: textColor, size: 28),
                      onPressed: () {
                        setState(() {
                          _currentDisplayedMonth = DateTime(
                            _currentDisplayedMonth.year,
                            _currentDisplayedMonth.month + 1,
                          );
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Calendar body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Day names row
                _buildDayNames(textColor),
                
                // Calendar days
                _buildCalendarDays(
                  textColor: textColor,
                  selectedColor: selectedColor,
                  todayColor: todayColor,
                  borderColor: borderColor,
                ),
              ],
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: _selectedDate != null ? () {
                    widget.onDateSelected(_selectedDate!);
                  } : null,
                  child: const Text(
                    'Select',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayNames(Color textColor) {
    final dayNames = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: dayNames.map((day) {
          return SizedBox(
            width: 36,
            child: Text(
              day,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarDays({
    required Color textColor,
    required Color selectedColor,
    required Color todayColor,
    required Color borderColor,
  }) {
    // Calculate the first day of the month
    final firstDayOfMonth = DateTime(_currentDisplayedMonth.year, _currentDisplayedMonth.month, 1);
    
    // Calculate the day of week (0 is Monday in our UI)
    int firstWeekdayOfMonth = firstDayOfMonth.weekday - 1;
    if (firstWeekdayOfMonth < 0) firstWeekdayOfMonth = 6; // Sunday adjustment
    
    // Calculate the number of days in the month
    final daysInMonth = DateTime(_currentDisplayedMonth.year, _currentDisplayedMonth.month + 1, 0).day;
    
    // Calculate days from previous month to show
    final daysFromPreviousMonth = firstWeekdayOfMonth;
    
    // Calculate total days to display (maximum 6 rows of 7 days)
    final totalDays = daysFromPreviousMonth + daysInMonth;
    final totalRows = (totalDays / 7).ceil();
    final totalCells = totalRows * 7;
    
    // Get days from previous month
    final lastDayOfPreviousMonth = DateTime(_currentDisplayedMonth.year, _currentDisplayedMonth.month, 0).day;
    final previousMonthDays = List.generate(
      daysFromPreviousMonth,
      (index) => lastDayOfPreviousMonth - daysFromPreviousMonth + index + 1,
    );
    
    // Get days from current month
    final currentMonthDays = List.generate(daysInMonth, (index) => index + 1);
    
    // Get days from next month
    final nextMonthDays = List.generate(
      totalCells - daysFromPreviousMonth - daysInMonth,
      (index) => index + 1,
    );
    
    // Combine all days
    final allDays = [
      ...previousMonthDays.map((day) => {'day': day, 'isCurrentMonth': false, 'isNextMonth': false}),
      ...currentMonthDays.map((day) => {'day': day, 'isCurrentMonth': true, 'isNextMonth': false}),
      ...nextMonthDays.map((day) => {'day': day, 'isCurrentMonth': false, 'isNextMonth': true}),
    ];
    
    // Today's date for highlighting
    final today = DateTime.now();
    final isCurrentMonthAndYear = today.year == _currentDisplayedMonth.year && today.month == _currentDisplayedMonth.month;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: allDays.length,
      itemBuilder: (context, index) {
        final dayData = allDays[index];
        final day = dayData['day'] as int;
        final isCurrentMonth = dayData['isCurrentMonth'] as bool;
        
        // Determine if this day is selected
        bool isSelected = false;
        if (_selectedDate != null && isCurrentMonth) {
          isSelected = _selectedDate!.year == _currentDisplayedMonth.year &&
                       _selectedDate!.month == _currentDisplayedMonth.month &&
                       _selectedDate!.day == day;
        }
        
        // Determine if this day is today
        final isToday = isCurrentMonthAndYear && today.day == day && isCurrentMonth;
        
        // Day color based on state
        Color dayColor = isCurrentMonth ? textColor : textColor.withValues(alpha: 0.3);
        Color dayBackgroundColor = Colors.transparent;
        
        if (isSelected) {
          dayColor = Colors.white;
          dayBackgroundColor = selectedColor;
        } else if (isToday) {
          dayColor = todayColor;
        }
        
        return InkWell(
          onTap: isCurrentMonth ? () {
            setState(() {
              _selectedDate = DateTime(_currentDisplayedMonth.year, _currentDisplayedMonth.month, day);
            });
          } : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: dayBackgroundColor,
              shape: BoxShape.circle,
              border: isToday && !isSelected ? Border.all(color: todayColor, width: 1.5) : null,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: selectedColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: dayColor,
                  fontSize: 16,
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
