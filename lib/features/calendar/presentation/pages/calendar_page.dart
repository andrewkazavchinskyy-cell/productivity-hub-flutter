import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../domain/entities/event.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../bloc/calendar_state.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CalendarBloc>()
        ..add(LoadCalendarEvents(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
        )),
      child: const CalendarView(),
    );
  }
}

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CalendarBloc>().add(RefreshCalendar()),
          ),
        ],
      ),
      body: BlocConsumer<CalendarBloc, CalendarState>(
        listener: (context, state) {
          if (state is CalendarLoaded && state.statusMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.statusMessage!)),
              );
          }
        },
        builder: (context, state) {
          if (state is CalendarLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CalendarError) {
            return _CalendarError(message: state.message);
          } else if (state is CalendarLoaded) {
            return Column(
              children: [
                _buildCalendarHeader(context, state),
                Expanded(
                  child: state.filteredEvents.isEmpty
                      ? const _EmptyState()
                      : _EventsList(
                          events: state.filteredEvents,
                          onEdit: (event) => _showEditEventDialog(context, event),
                          onDelete: (event) => _showDeleteConfirmation(context, event),
                        ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context, CalendarLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'События',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${state.filteredEvents.length} событий',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => _showDatePicker(context),
            icon: const Icon(Icons.calendar_today),
            label: Text(
              '${state.selectedDate.day.toString().padLeft(2, '0')}.${state.selectedDate.month.toString().padLeft(2, '0')}.${state.selectedDate.year}',
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final queryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поиск событий'),
        content: TextField(
          controller: queryController,
          decoration: const InputDecoration(
            hintText: 'Введите название или описание',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (query) => _search(context, query),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CalendarBloc>().add(const SearchEvents(''));
            },
            child: const Text('Сбросить'),
          ),
          TextButton(
            onPressed: () {
              _search(context, queryController.text);
              Navigator.pop(context);
            },
            child: const Text('Найти'),
          ),
        ],
      ),
    );
  }

  void _search(BuildContext context, String query) {
    context.read<CalendarBloc>().add(SearchEvents(query.trim()));
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((selectedDate) {
      if (selectedDate != null) {
        context.read<CalendarBloc>().add(SelectDate(selectedDate));
      }
    });
  }

  void _showCreateEventDialog(BuildContext context) {
    final bloc = context.read<CalendarBloc>();
    final selectedDate = bloc.state is CalendarLoaded
        ? (bloc.state as CalendarLoaded).selectedDate
        : DateTime.now();
    final formData = _EventFormData.initial(selectedDate: selectedDate);

    _showEventFormDialog(
      context,
      title: 'Новое событие',
      formData: formData,
      onSubmit: (data) {
        final event = Event(
          id: data.id,
          title: data.title,
          description: data.description,
          startTime: data.startDateTime,
          endTime: data.endDateTime,
          location: data.location,
          isAllDay: data.isAllDay,
          attendees: data.attendees,
          reminderMinutes: data.reminderMinutes,
        );
        bloc.add(CreateEvent(event));
      },
    );
  }

  void _showEditEventDialog(BuildContext context, Event event) {
    final formData = _EventFormData.fromEvent(event);

    _showEventFormDialog(
      context,
      title: 'Редактирование события',
      formData: formData,
      onSubmit: (data) {
        final updatedEvent = event.copyWith(
          title: data.title,
          description: data.description,
          startTime: data.startDateTime,
          endTime: data.endDateTime,
          location: data.location,
          attendees: data.attendees,
          isAllDay: data.isAllDay,
          reminderMinutes: data.reminderMinutes,
        );
        context.read<CalendarBloc>().add(UpdateEvent(updatedEvent));
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить событие'),
        content: Text('Вы уверены, что хотите удалить событие "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<CalendarBloc>().add(DeleteEvent(event.id));
              Navigator.pop(context);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _showEventFormDialog(
    BuildContext context, {
    required String title,
    required _EventFormData formData,
    required ValueChanged<_EventFormData> onSubmit,
  }) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: formData.title);
    final descriptionController = TextEditingController(text: formData.description);
    final locationController = TextEditingController(text: formData.location);
    final attendeesController = TextEditingController(text: formData.attendees.join(', '));

    TimeOfDay startTime = TimeOfDay.fromDateTime(formData.startDateTime);
    TimeOfDay endTime = TimeOfDay.fromDateTime(formData.endDateTime);
    DateTime selectedDate = formData.startDateTime;
    bool isAllDay = formData.isAllDay;
    int reminderMinutes = formData.reminderMinutes;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickTime({required bool forStart}) async {
              final initialTime = forStart ? startTime : endTime;
              final result = await showTimePicker(
                context: context,
                initialTime: initialTime,
              );

              if (result != null) {
                setState(() {
                  if (forStart) {
                    startTime = result;
                    if (!isAllDay && _combine(selectedDate, endTime).isBefore(_combine(selectedDate, startTime))) {
                      endTime = TimeOfDay(
                        hour: (startTime.hour + 1) % 24,
                        minute: startTime.minute,
                      );
                    }
                  } else {
                    endTime = result;
                  }
                });
              }
            }

            Future<void> pickDate() async {
              final result = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );

              if (result != null) {
                setState(() => selectedDate = result);
              }
            }

            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Название',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите название события';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Описание',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: pickDate,
                              icon: const Icon(Icons.event),
                              label: Text(
                                '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                              ),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              value: isAllDay,
                              onChanged: (value) => setState(() => isAllDay = value ?? false),
                              title: const Text('Весь день'),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        ],
                      ),
                      if (!isAllDay) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => pickTime(forStart: true),
                                icon: const Icon(Icons.schedule),
                                label: Text('${startTime.format(context)}'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => pickTime(forStart: false),
                                icon: const Icon(Icons.schedule),
                                label: Text('${endTime.format(context)}'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Место',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: attendeesController,
                        decoration: const InputDecoration(
                          labelText: 'Участники (через запятую)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: reminderMinutes,
                        decoration: const InputDecoration(
                          labelText: 'Напоминание',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Без напоминания')),
                          DropdownMenuItem(value: 5, child: Text('За 5 минут')),
                          DropdownMenuItem(value: 15, child: Text('За 15 минут')),
                          DropdownMenuItem(value: 30, child: Text('За 30 минут')),
                          DropdownMenuItem(value: 60, child: Text('За 1 час')),
                        ],
                        onChanged: (value) => setState(() => reminderMinutes = value ?? reminderMinutes),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final startDateTime = isAllDay
                          ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
                          : _combine(selectedDate, startTime);
                      final endDateTime = isAllDay
                          ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59)
                          : _combine(selectedDate, endTime);

                      final attendees = attendeesController.text
                          .split(',')
                          .map((item) => item.trim())
                          .where((item) => item.isNotEmpty)
                          .toList();

                      onSubmit(
                        formData.copyWith(
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim().isEmpty
                              ? null
                              : descriptionController.text.trim(),
                          location: locationController.text.trim().isEmpty
                              ? null
                              : locationController.text.trim(),
                          attendees: attendees,
                          isAllDay: isAllDay,
                          reminderMinutes: reminderMinutes,
                          startDateTime: startDateTime,
                          endDateTime: endDateTime,
                        ),
                      );

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({
    required this.events,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Event> events;
  final ValueChanged<Event> onEdit;
  final ValueChanged<Event> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () => _showDetails(context, event),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                event.startTime.hour.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.description != null) Text(event.description!),
                const SizedBox(height: 4),
                Text(
                  event.isAllDay
                      ? 'Весь день'
                      : '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')} - '
                        '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (event.location != null)
                  Text(
                    '📍 ${event.location}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit(event);
                } else if (value == 'delete') {
                  onDelete(event);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Редактировать'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Удалить'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetails(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (event.description != null)
                Text(
                  event.description!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.isAllDay
                          ? 'Весь день'
                          : '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')} - '
                            '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (event.location != null)
                Row(
                  children: [
                    const Icon(Icons.place, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(event.location!)),
                  ],
                ),
              if (event.attendees.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Участники:'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: event.attendees
                      .map((attendee) => Chip(label: Text(attendee)))
                      .toList(),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit(event);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Редактировать'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete(event);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Удалить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Нет событий',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Создайте ваше первое событие',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _CalendarError extends StatelessWidget {
  const _CalendarError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки календаря',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<CalendarBloc>().add(RefreshCalendar()),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}

class _EventFormData {
  const _EventFormData({
    required this.id,
    required this.title,
    required this.startDateTime,
    required this.endDateTime,
    this.description,
    this.location,
    this.attendees = const [],
    this.isAllDay = false,
    this.reminderMinutes = 15,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String? location;
  final List<String> attendees;
  final bool isAllDay;
  final int reminderMinutes;

  static _EventFormData initial({required DateTime selectedDate}) {
    final id = 'event-${DateTime.now().microsecondsSinceEpoch}';
    final start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 9, 0);
    final end = start.add(const Duration(hours: 1));
    return _EventFormData(
      id: id,
      title: '',
      startDateTime: start,
      endDateTime: end,
    );
  }

  static _EventFormData fromEvent(Event event) {
    return _EventFormData(
      id: event.id,
      title: event.title,
      description: event.description,
      startDateTime: event.startTime,
      endDateTime: event.endTime,
      location: event.location,
      attendees: event.attendees,
      isAllDay: event.isAllDay,
      reminderMinutes: event.reminderMinutes,
    );
  }

  _EventFormData copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
    List<String>? attendees,
    bool? isAllDay,
    int? reminderMinutes,
  }) {
    return _EventFormData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      isAllDay: isAllDay ?? this.isAllDay,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }
}
