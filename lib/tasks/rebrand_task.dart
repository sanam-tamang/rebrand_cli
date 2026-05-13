/// A unit of work executed by [RebrandService].
///
/// Each task should expose a human-readable [name] used by the CLI output and
/// implement [execute] to perform a single piece of the rebranding process.
abstract class RebrandTask {
  String get name;
  Future<void> execute();
}
