/**
 * Utility class for detecting Apex object types.
 * 
 * Provides type detection methods to determine if a value is primitive,
 * collection, or complex type for proper TOON encoding.
 */
public class ToonTypeHelper {
    
    /**
     * Check if a value is a primitive type (or null).
     * Primitives: null, Boolean, Integer, Long, Decimal, Double, String
     */
    public static Boolean isPrimitive(Object value) {
        return value == null
            || value instanceof Boolean
            || value instanceof Integer
            || value instanceof Long
            || value instanceof Decimal
            || value instanceof Double
            || value instanceof String;
    }
    
    /**
     * Check if a value is a List/array.
     */
    public static Boolean isList(Object value) {
        if (value == null) {
            return false;
        }
        return value instanceof List<Object>;
    }
    
    /**
     * Check if a value is a Map/object.
     */
    public static Boolean isMap(Object value) {
        if (value == null) {
            return false;
        }
        return value instanceof Map<String, Object>;
    }
    
    /**
     * Check if a value is an SObject.
     */
    public static Boolean isSObject(Object value) {
        if (value == null) {
            return false;
        }
        return value instanceof SObject;
    }
    
    /**
     * Get a human-readable type name for error messages.
     */
    public static String getTypeName(Object value) {
        if (value == null) {
            return 'null';
        }
        
        if (value instanceof Boolean) {
            return 'Boolean';
        }
        if (value instanceof Integer) {
            return 'Integer';
        }
        if (value instanceof Long) {
            return 'Long';
        }
        if (value instanceof Decimal) {
            return 'Decimal';
        }
        if (value instanceof Double) {
            return 'Double';
        }
        if (value instanceof String) {
            return 'String';
        }
        if (value instanceof List<Object>) {
            return 'List';
        }
        if (value instanceof Map<String, Object>) {
            return 'Map';
        }
        if (value instanceof SObject) {
            SObject obj = (SObject) value;
            return 'SObject(' + obj.getSObjectType().getDescribe().getName() + ')';
        }
        
        return 'Unknown';
    }
    
    /**
     * Check if all items in a list are primitives.
     * Used to determine if array can use inline format.
     */
    public static Boolean areAllPrimitives(List<Object> items) {
        if (items == null || items.isEmpty()) {
            return true;
        }
        
        for (Object item : items) {
            if (!isPrimitive(item)) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Check if all items in a list are Maps (objects).
     * Used to determine if array can use tabular format.
     */
    public static Boolean areAllMaps(List<Object> items) {
        if (items == null || items.isEmpty()) {
            return false;
        }
        
        for (Object item : items) {
            if (!isMap(item)) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Check if all Maps in a list have the same keys (uniform structure).
     * Required for tabular format.
     */
    public static Boolean haveUniformKeys(List<Object> items) {
        if (items == null || items.size() <= 1) {
            return true;
        }
        
        if (!areAllMaps(items)) {
            return false;
        }
        
        Map<String, Object> firstItem = (Map<String, Object>) items[0];
        Set<String> expectedKeys = firstItem.keySet();
        
        for (Integer i = 1; i < items.size(); i++) {
            Map<String, Object> currentItem = (Map<String, Object>) items[i];
            Set<String> currentKeys = currentItem.keySet();
            
            if (expectedKeys.size() != currentKeys.size()) {
                return false;
            }
            
            for (String key : expectedKeys) {
                if (!currentKeys.contains(key)) {
                    return false;
                }
            }
        }
        
        return true;
    }
    
    /**
     * Get the list of keys from the first Map in a list.
     * Used for tabular header generation.
     */
    public static List<String> getUniformKeys(List<Object> items) {
        if (items == null || items.isEmpty() || !isMap(items[0])) {
            return new List<String>();
        }
        
        Map<String, Object> firstItem = (Map<String, Object>) items[0];
        return new List<String>(firstItem.keySet());
    }
}
