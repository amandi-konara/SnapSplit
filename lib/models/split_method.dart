/// How one item's amount is divided between the people assigned to it.
enum SplitMethod {
  /// Everyone pays the same; leftover cents go to the first person.
  equal('equal', 'Equal'),

  /// Each person's share is typed in as an amount in cents.
  exact('exact', 'Exact'),

  /// Each person's share is a percentage, stored in basis points.
  percentage('percentage', 'Percent');

  const SplitMethod(this.dbValue, this.label);

  /// Value stored in the database `split_method` column.
  final String dbValue;

  /// Label shown on the Equal / Exact / Percent switch.
  final String label;

  static SplitMethod fromDb(String value) => SplitMethod.values.firstWhere(
    (m) => m.dbValue == value,
    orElse: () => SplitMethod.equal,
  );
}
