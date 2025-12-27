// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskViewModel)
const taskViewModelProvider = TaskViewModelFamily._();

final class TaskViewModelProvider
    extends $StreamNotifierProvider<TaskViewModel, List<Task>> {
  const TaskViewModelProvider._({
    required TaskViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskViewModelHash();

  @override
  String toString() {
    return r'taskViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskViewModel create() => TaskViewModel();

  @override
  bool operator ==(Object other) {
    return other is TaskViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskViewModelHash() => r'a97338c5b0b89436ee84200bbdc0efc4b0ef0570';

final class TaskViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskViewModel,
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>,
          String
        > {
  const TaskViewModelFamily._()
    : super(
        retry: null,
        name: r'taskViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TaskViewModelProvider call(String projectId) =>
      TaskViewModelProvider._(argument: projectId, from: this);

  @override
  String toString() => r'taskViewModelProvider';
}

abstract class _$TaskViewModel extends $StreamNotifier<List<Task>> {
  late final _$args = ref.$arg as String;
  String get projectId => _$args;

  Stream<List<Task>> build(String projectId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<Task>>, List<Task>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Task>>, List<Task>>,
              AsyncValue<List<Task>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
