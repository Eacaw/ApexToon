/**
 * Integration tests for ApexToon encoding.
 * Tests the complete encoding pipeline from ApexToon.encode() down.
 */
@IsTest
private class ApexToonEncodingTest {
    
    @IsTest
    private static void testEncodePrimitiveNull() {
        // Given
        Object value = null;

        // When
        Test.startTest();
        String result = ApexToon.encode(value);
        Test.stopTest();

        // Then
        Assert.areEqual('null', result, 'Should encode null');
    }
    
    @IsTest
    private static void testEncodePrimitiveBoolean() {
        // Given
        Boolean value = true;

        // When
        Test.startTest();
        String result = ApexToon.encode(value);
        Test.stopTest();

        // Then
        Assert.areEqual('true', result, 'Should encode boolean');
    }
    
    @IsTest
    private static void testEncodePrimitiveNumber() {
        // Given
        Integer value = 42;

        // When
        Test.startTest();
        String result = ApexToon.encode(value);
        Test.stopTest();

        // Then
        Assert.areEqual('42', result, 'Should encode number');
    }
    
    @IsTest
    private static void testEncodePrimitiveString() {
        // Given
        String value = 'hello';

        // When
        Test.startTest();
        String result = ApexToon.encode(value);
        Test.stopTest();

        // Then
        Assert.areEqual('hello', result, 'Should encode string');
    }
    
    @IsTest
    private static void testEncodeSimpleObject() {
        // Given
        Map<String, Object> obj = new Map<String, Object>{
            'id' => 123,
            'name' => 'Ada',
            'active' => true
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(obj);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('id: 123'), 'Should contain id field');
        Assert.isTrue(result.contains('name: Ada'), 'Should contain name field');
        Assert.isTrue(result.contains('active: true'), 'Should contain active field');
    }
    
    @IsTest
    private static void testEncodeNestedObject() {
        // Given
        Map<String, Object> obj = new Map<String, Object>{
            'id' => 1,
            'user' => new Map<String, Object>{
                'name' => 'Alice',
                'age' => 30
            }
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(obj);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('id: 1'), 'Should contain id');
        Assert.isTrue(result.contains('user:'), 'Should contain user key');
        Assert.isTrue(result.contains('name: Alice'), 'Should contain nested name');
        Assert.isTrue(result.contains('age: 30'), 'Should contain nested age');
    }
    
    @IsTest
    private static void testEncodePrimitiveArray() {
        // Given
        List<Object> arrayResult = new List<Object>{ 'admin', 'ops', 'dev' };

        // When
        Test.startTest();
        String result = ApexToon.encode(arrayResult);
        Test.stopTest();

        // Then
        Assert.isTrue(result.startsWith('[3]:'), 'Should have arrayResult header');
        Assert.isTrue(result.contains('admin'), 'Should contain first item');
        Assert.isTrue(result.contains('ops'), 'Should contain second item');
        Assert.isTrue(result.contains('dev'), 'Should contain third item');
    }
    
    @IsTest
    private static void testEncodeTabularArray() {
        // Given
        List<Object> arrayResult = new List<Object>{
            new Map<String, Object>{ 'id' => 1, 'name' => 'Alice' },
            new Map<String, Object>{ 'id' => 2, 'name' => 'Bob' }
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(arrayResult);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('[2]{'), 'Should have tabular header with length');
        Assert.isTrue(result.contains('id'), 'Should contain id field in header');
        Assert.isTrue(result.contains('name'), 'Should contain name field in header');
        Assert.isTrue(result.contains('1'), 'Should contain first row data');
        Assert.isTrue(result.contains('Alice'), 'Should contain first row name');
        Assert.isTrue(result.contains('2'), 'Should contain second row data');
        Assert.isTrue(result.contains('Bob'), 'Should contain second row name');
    }
    
    @IsTest
    private static void testEncodeObjectWithArray() {
        // Given
        Map<String, Object> obj = new Map<String, Object>{
            'user' => 'Alice',
            'tags' => new List<Object>{ 'admin', 'dev' }
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(obj);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('user: Alice'), 'Should contain user field');
        Assert.isTrue(result.contains('tags[2]:'), 'Should contain tags arrayResult header');
        Assert.isTrue(result.contains('admin'), 'Should contain tag value');
        Assert.isTrue(result.contains('dev'), 'Should contain tag value');
    }
    
    @IsTest
    private static void testEncodeWithCustomOptions() {
        // Given
        Map<String, Object> obj = new Map<String, Object>{
            'id' => 1,
            'nested' => new Map<String, Object>{
                'value' => 'test'
            }
        };
        EncodeOptions options = new EncodeOptions(4, ToonDelimiter.COMMA, false);

        // When
        Test.startTest();
        String result = ApexToon.encode(obj, options);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('nested:'), 'Should contain nested key');
        Assert.isTrue(result.contains('    value: test'), 'Should use 4-space indentation');
    }
    
    @IsTest
    private static void testEncodeJson() {
        // Given
        String jsonStr = '{"id":123,"name":"Ada"}';

        // When
        Test.startTest();
        String result = ApexToon.encodeJson(jsonStr);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('id: 123'), 'Should contain id');
        Assert.isTrue(result.contains('name: Ada'), 'Should contain name');
    }
    
    @IsTest
    private static void testEncodeEmptyObject() {
        // Given
        Map<String, Object> obj = new Map<String, Object>();

        // When
        Test.startTest();
        String result = ApexToon.encode(obj);
        Test.stopTest();

        // Then
        Assert.areEqual('', result, 'Empty object should produce empty string');
    }
    
    @IsTest
    private static void testEncodeEmptyArray() {
        // Given
        List<Object> arrayResult = new List<Object>();

        // When
        Test.startTest();
        String result = ApexToon.encode(arrayResult);
        Test.stopTest();

        // Then
        Assert.areEqual('[0]:', result, 'Empty arrayResult should have zero length header');
    }
    
    @IsTest
    private static void testEncodeMixedArray() {
        // Given
        List<Object> arrayResult = new List<Object>{
            'string',
            123,
            new Map<String, Object>{ 'key' => 'value' }
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(arrayResult);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('[3]:'), 'Should have list header');
        Assert.isTrue(result.contains('- string'), 'Should contain string item');
        Assert.isTrue(result.contains('- 123'), 'Should contain number item');
        Assert.isTrue(result.contains('- key: value'), 'Should contain object item');
    }
    
    @IsTest
    private static void testEncodeComplexNested() {
        // Given
        Map<String, Object> obj = new Map<String, Object>{
            'project' => 'TOON',
            'metadata' => new Map<String, Object>{
                'version' => '1.0',
                'authors' => new List<Object>{ 'Alice', 'Bob' }
            },
            'items' => new List<Object>{
                new Map<String, Object>{ 'id' => 1, 'status' => 'active' },
                new Map<String, Object>{ 'id' => 2, 'status' => 'pending' }
            }
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(obj);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('project: TOON'), 'Should contain project');
        Assert.isTrue(result.contains('metadata:'), 'Should contain metadata');
        Assert.isTrue(result.contains('version:'), 'Should contain version');
        Assert.isTrue(result.contains('authors'), 'Should contain authors arrayResult');
        Assert.isTrue(result.contains('items'), 'Should contain items tabular arrayResult');
        Assert.isTrue(result.contains('active'), 'Should contain status value');
    }
}
