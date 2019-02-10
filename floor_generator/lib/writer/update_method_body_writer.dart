import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/update_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class UpdateMethodBodyWriter implements Writer {
  final LibraryReader library;
  final UpdateMethod method;

  UpdateMethodBodyWriter(this.library, this.method);

  @override
  Code write() {
    return Code(_generateMethodBody());
  }

  String _generateMethodBody() {
    final parameter = method.parameter;
    final methodHeadParameterName = parameter.displayName;

    final columnNames =
        method.getEntity(library).columns.map((column) => column.name).toList();
    final constructorParameters =
        (parameter.type.element as ClassElement).constructors.first.parameters;

    final keyValueList = <String>[];

    for (var i = 0; i < constructorParameters.length; i++) {
      final valueMapping =
          _getValueMapping(constructorParameters[i], methodHeadParameterName);
      keyValueList.add("'${columnNames[i]}': $valueMapping");
    }

    final entityName = method.getEntity(library).name;

    return '''
    final values = <String, dynamic>{
      ${keyValueList.join(', ')}
    };
    await database.update('$entityName', values);
    ''';
  }

  String _getValueMapping(
    final ParameterElement parameter,
    final String methodParameterName,
  ) {
    final parameterName = parameter.displayName;

    if (isBool(parameter.type)) {
      return '$methodParameterName.$parameterName ? 1 : 0';
    } else {
      return '$methodParameterName.$parameterName';
    }
  }
}