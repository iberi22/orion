// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_memory_service.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMemoryNodeCollection on Isar {
  IsarCollection<MemoryNode> get memoryNodes => this.collection();
}

const MemoryNodeSchema = CollectionSchema(
  name: r'MemoryNode',
  id: 1001,
  properties: {
    r'aiResponse': PropertySchema(
      id: 0,
      name: r'aiResponse',
      type: IsarType.string,
    ),
    r'content': PropertySchema(id: 1, name: r'content', type: IsarType.string),
    r'metadata': PropertySchema(
      id: 2,
      name: r'metadata',
      type: IsarType.string,
    ),
    r'similarity': PropertySchema(
      id: 3,
      name: r'similarity',
      type: IsarType.double,
    ),
    r'timestamp': PropertySchema(
      id: 4,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'userInput': PropertySchema(
      id: 5,
      name: r'userInput',
      type: IsarType.string,
    ),
  },
  estimateSize: _memoryNodeEstimateSize,
  serialize: _memoryNodeSerialize,
  deserialize: _memoryNodeDeserialize,
  deserializeProp: _memoryNodeDeserializeProp,
  idName: r'id',
  indexes: {
    r'content': IndexSchema(
      id: 1002,
      name: r'content',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'content',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1003,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _memoryNodeGetId,
  getLinks: _memoryNodeGetLinks,
  attach: _memoryNodeAttach,
  version: '3.1.0+1',
);

int _memoryNodeEstimateSize(
  MemoryNode object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aiResponse.length * 3;
  bytesCount += 3 + object.content.length * 3;
  {
    final value = object.metadata;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.userInput.length * 3;
  return bytesCount;
}

void _memoryNodeSerialize(
  MemoryNode object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiResponse);
  writer.writeString(offsets[1], object.content);
  writer.writeString(offsets[2], object.metadata);
  writer.writeDouble(offsets[3], object.similarity);
  writer.writeDateTime(offsets[4], object.timestamp);
  writer.writeString(offsets[5], object.userInput);
}

MemoryNode _memoryNodeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MemoryNode();
  object.aiResponse = reader.readString(offsets[0]);
  object.content = reader.readString(offsets[1]);
  object.id = id;
  object.metadata = reader.readStringOrNull(offsets[2]);
  object.similarity = reader.readDouble(offsets[3]);
  object.timestamp = reader.readDateTime(offsets[4]);
  object.userInput = reader.readString(offsets[5]);
  return object;
}

P _memoryNodeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _memoryNodeGetId(MemoryNode object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _memoryNodeGetLinks(MemoryNode object) {
  return [];
}

void _memoryNodeAttach(IsarCollection<dynamic> col, Id id, MemoryNode object) {
  object.id = id;
}

extension MemoryNodeQueryWhereSort
    on QueryBuilder<MemoryNode, MemoryNode, QWhere> {
  QueryBuilder<MemoryNode, MemoryNode, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension MemoryNodeQueryWhere
    on QueryBuilder<MemoryNode, MemoryNode, QWhereClause> {
  QueryBuilder<MemoryNode, MemoryNode, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterWhereClause> contentEqualTo(
    String content,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'content', value: [content]),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterWhereClause> contentNotEqualTo(
    String content,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'content',
                lower: [],
                upper: [content],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'content',
                lower: [content],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'content',
                lower: [content],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'content',
                lower: [],
                upper: [content],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterWhereClause> timestampEqualTo(
    DateTime timestamp,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'timestamp', value: [timestamp]),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterWhereClause> timestampNotEqualTo(
    DateTime timestamp,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterWhereClause> timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [timestamp],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterWhereClause> timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [],
          upper: [timestamp],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterWhereClause> timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [lowerTimestamp],
          includeLower: includeLower,
          upper: [upperTimestamp],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension MemoryNodeQueryFilter
    on QueryBuilder<MemoryNode, MemoryNode, QFilterCondition> {
  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> aiResponseEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aiResponse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  aiResponseGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aiResponse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  aiResponseLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aiResponse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> aiResponseBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aiResponse',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  aiResponseStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'aiResponse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  aiResponseEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'aiResponse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  aiResponseContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'aiResponse',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> aiResponseMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'aiResponse',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  aiResponseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'aiResponse', value: ''),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  aiResponseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'aiResponse', value: ''),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'content',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'content',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'content',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'content',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'content',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'content',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> contentContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'content',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> contentMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'content',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'content', value: ''),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'content', value: ''),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> metadataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'metadata'),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  metadataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'metadata'),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> metadataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'metadata',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  metadataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'metadata',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> metadataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'metadata',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> metadataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'metadata',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  metadataStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'metadata',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> metadataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'metadata',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> metadataContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'metadata',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> metadataMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'metadata',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  metadataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'metadata', value: ''),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  metadataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'metadata', value: ''),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> similarityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'similarity',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  similarityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'similarity',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  similarityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'similarity',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> similarityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'similarity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> timestampEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> userInputEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'userInput',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  userInputGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userInput',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> userInputLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userInput',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> userInputBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userInput',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  userInputStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'userInput',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> userInputEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'userInput',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> userInputContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'userInput',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition> userInputMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'userInput',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  userInputIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userInput', value: ''),
      );
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterFilterCondition>
  userInputIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userInput', value: ''),
      );
    });
  }
}

extension MemoryNodeQueryObject
    on QueryBuilder<MemoryNode, MemoryNode, QFilterCondition> {}

extension MemoryNodeQueryLinks
    on QueryBuilder<MemoryNode, MemoryNode, QFilterCondition> {}

extension MemoryNodeQuerySortBy
    on QueryBuilder<MemoryNode, MemoryNode, QSortBy> {
  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> sortByAiResponse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiResponse', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> sortByAiResponseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiResponse', Sort.desc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> sortByMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> sortByMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.desc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> sortBySimilarity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'similarity', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> sortBySimilarityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'similarity', Sort.desc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> sortByUserInput() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userInput', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> sortByUserInputDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userInput', Sort.desc);
    });
  }
}

extension MemoryNodeQuerySortThenBy
    on QueryBuilder<MemoryNode, MemoryNode, QSortThenBy> {
  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenByAiResponse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiResponse', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenByAiResponseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiResponse', Sort.desc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenByMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenByMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.desc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenBySimilarity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'similarity', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenBySimilarityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'similarity', Sort.desc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenByUserInput() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userInput', Sort.asc);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QAfterSortBy> thenByUserInputDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userInput', Sort.desc);
    });
  }
}

extension MemoryNodeQueryWhereDistinct
    on QueryBuilder<MemoryNode, MemoryNode, QDistinct> {
  QueryBuilder<MemoryNode, MemoryNode, QDistinct> distinctByAiResponse({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiResponse', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QDistinct> distinctByContent({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QDistinct> distinctByMetadata({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadata', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QDistinct> distinctBySimilarity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'similarity');
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<MemoryNode, MemoryNode, QDistinct> distinctByUserInput({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userInput', caseSensitive: caseSensitive);
    });
  }
}

extension MemoryNodeQueryProperty
    on QueryBuilder<MemoryNode, MemoryNode, QQueryProperty> {
  QueryBuilder<MemoryNode, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MemoryNode, String, QQueryOperations> aiResponseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiResponse');
    });
  }

  QueryBuilder<MemoryNode, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<MemoryNode, String?, QQueryOperations> metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<MemoryNode, double, QQueryOperations> similarityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'similarity');
    });
  }

  QueryBuilder<MemoryNode, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<MemoryNode, String, QQueryOperations> userInputProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userInput');
    });
  }
}
