/**
 * Encoder for Salesforce SObjects with explicit field selection.
 * 
 * Provides specialized encoding for SObjects with:
 * - Explicit field selection via SObjectField or field names
 * - Relationship field support (dot notation)
 * - Field-level security filtering
 * - Tabular format for uniform records
 */
public class ToonSObjectEncoder {
    
    /**
     * Encode SObjects with explicit field selection using SObjectField.
     */
    public static String encodeSObjects(List<SObject> records, List<Schema.SObjectField> fields, EncodeOptions options) {
        if (records == null || records.isEmpty()) {
            return '[0]:';
        }
        
        Schema.SObjectType recordType = records[0].getSObjectType();
        validateSameType(records, recordType);
        
        List<Object> mappedRecords = new List<Object>();
        for (SObject record : records) {
            Map<String, Object> mapped = sObjectToMap(record, fields);
            if (!mapped.isEmpty()) {
                mappedRecords.add(mapped);
            }
        }
        
        return encodeSObjectsWithType(mappedRecords, recordType, options);
    }
    
    /**
     * Encode SObjects with field names (supports relationships via dot notation).
     */
    public static String encodeSObjects(List<SObject> records, List<String> fieldNames, EncodeOptions options) {
        if (records == null || records.isEmpty()) {
            return '[0]:';
        }
        
        Schema.SObjectType recordType = records[0].getSObjectType();
        validateSameType(records, recordType);
        
        List<Object> mappedRecords = new List<Object>();
        for (SObject record : records) {
            Map<String, Object> mapped = sObjectToMapByFieldNames(record, fieldNames);
            if (!mapped.isEmpty()) {
                mappedRecords.add(mapped);
            }
        }
        
        return encodeSObjectsWithType(mappedRecords, recordType, options);
    }
    
    /**
     * Encode SObjects with type metadata included.
     * Wraps the encoded records with SObject type information.
     */
    private static String encodeSObjectsWithType(List<Object> mappedRecords, Schema.SObjectType sObjectType, EncodeOptions options) {
        String sObjectName = sObjectType.getDescribe().getName();
        
        Map<String, Object> wrapper = new Map<String, Object>();
        wrapper.put('__sObjectType', sObjectName);
        wrapper.put('records', mappedRecords);
        
        return ApexToon.encode(wrapper, options);
    }
    
    /**
     * Convert SObject to Map using SObjectField list.
     */
    public static Map<String, Object> sObjectToMap(SObject record, List<Schema.SObjectField> fields) {
        Map<String, Object> result = new Map<String, Object>();
        
        if (record == null || fields == null || fields.isEmpty()) {
            return result;
        }
        
        for (Schema.SObjectField field : fields) {
            String fieldName = field.getDescribe().getName();
            Object value = record.get(field);
            
            if (value == null) {
                continue;
            }
            
            result.put(fieldName, normalizeFieldValue(value));
        }
        
        return result;
    }
    
    /**
     * Convert SObject to Map using field name strings (supports relationships).
     */
    public static Map<String, Object> sObjectToMapByFieldNames(SObject record, List<String> fieldNames) {
        Map<String, Object> result = new Map<String, Object>();
        
        if (record == null || fieldNames == null || fieldNames.isEmpty()) {
            return result;
        }
        
        for (String fieldName : fieldNames) {
            Object value = getFieldValue(record, fieldName);
            
            if (value == null) {
                continue;
            }
            
            result.put(fieldName, normalizeFieldValue(value));
        }
        
        return result;
    }
    
    /**
     * Get field value supporting dot notation for relationships.
     */
    private static Object getFieldValue(SObject record, String fieldPath) {
        if (!fieldPath.contains('.')) {
            return record.get(fieldPath);
        }
        
        List<String> parts = fieldPath.split('\\.');
        SObject current = record;
        
        for (Integer i = 0; i < parts.size() - 1; i++) {
            current = current.getSObject(parts[i]);
            if (current == null) {
                return null;
            }
        }
        
        return current.get(parts[parts.size() - 1]);
    }
    
    /**
     * Normalize field values for TOON encoding.
     */
    private static Object normalizeFieldValue(Object value) {
        if (value == null) {
            return null;
        }
        
        if (value instanceof Date) {
            return ((Date) value).format();
        }
        
        if (value instanceof DateTime) {
            return ((DateTime) value).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }
        
        if (value instanceof Time) {
            return String.valueOf(value);
        }
        
        if (value instanceof List<SObject>) {
            String jsonStr = JSON.serialize(value);
            return JSON.deserializeUntyped(jsonStr);
        }
        
        return value;
    }
    
    /**
     * Validate all records are same SObject type.
     */
    private static void validateSameType(List<SObject> records, Schema.SObjectType expectedType) {
        for (SObject record : records) {
            if (record.getSObjectType() != expectedType) {
                throw new ToonEncodingException(
                    'Mixed SObject types not supported. Expected: ' + expectedType.getDescribe().getName() +
                    ', Found: ' + record.getSObjectType().getDescribe().getName()
                );
            }
        }
    }
    
    /**
     * Get all accessible fields for an SObject type.
     */
    public static List<Schema.SObjectField> getAccessibleFields(Schema.SObjectType sObjectType) {
        List<Schema.SObjectField> accessibleFields = new List<Schema.SObjectField>();
        Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
        
        for (Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            
            if (fieldDescribe.isAccessible()) {
                accessibleFields.add(field);
            }
        }
        
        return accessibleFields;
    }
}
