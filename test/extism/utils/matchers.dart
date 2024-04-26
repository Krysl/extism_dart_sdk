import 'package:json_schema/json_schema.dart';

import 'package:test/test.dart';

class SchemaMatcher extends Matcher {
  final JsonSchema schema;
  bool parseJson;

  SchemaMatcher(this.schema, {this.parseJson = true});
  @override
  bool matches(dynamic item, Map matchState) {
    final results = schema.validate(item, parseJson: parseJson);

    if (results.isValid) {
      return true;
    } else {
      addStateInfo(matchState, {
        'results': '${results.errors.isEmpty ? 'VALID' : 'INVALID'}'
            '${results.errors.isNotEmpty ? ', Errors: ${results.errors.join('\n')}' : ''}'
            '${results.warnings.isNotEmpty ? ', Warnings: ${results.warnings.join('\n')}' : ''}',
      });
      return false;
    }
  }

  final String _featureDescription = 'SchemaMatcher';
  @override
  Description describe(Description description) =>
      description.add(_featureDescription).add(' ');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (matchState['results'] != null) {
      mismatchDescription.add('threw ').addDescriptionOf(matchState['results']);
      return mismatchDescription;
    }
    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}
