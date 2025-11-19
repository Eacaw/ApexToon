/**
 * Main orchestrator for decoding TOON format to Apex objects.
 * 
 * Handles parsing of complete TOON documents into Map/List structures.
 */
public class ToonValueDecoder {
    
    /**
     * Decode TOON string to Apex object with default options.
     */
    public static Object decode(String toon) {
        return decode(toon, new DecodeOptions());
    }
    
    /**
     * Decode TOON string to Apex object with custom options.
     */
    public static Object decode(String toon, DecodeOptions options) {
        if (String.isBlank(toon)) {
            return new Map<String, Object>();
        }
        
        String trimmed = toon.trim();
        
        if (trimmed == 'null') {
            return null;
        }
        
        ToonParser parser = new ToonParser(toon, options);
        Object result = parseValue(parser, 0);
        
        return result != null ? result : new Map<String, Object>();
    }
    
    /**
     * Parse a value at the current parser position.
     */
    private static Object parseValue(ToonParser parser, Integer depth) {
        if (!parser.hasMoreLines()) {
            return null;
        }
        
        String line = parser.getLine(parser.getCurrentLineNumber());
        Integer lineDepth = parser.getDepth(line);
        
        if (lineDepth > depth) {
            throw new ToonDecodingException('Unexpected indentation at line ' + parser.getCurrentLineNumber());
        }
        
        String content = parser.getCurrentContent(depth);
        
        // Check for list item array (starts with '- ')
        if (content.startsWith('- ')) {
            return parseListArray(parser, depth - 1);
        }
        
        if (parser.isArrayHeader(content)) {
            return parseArray(parser, content, depth);
        }
        
        if (parser.isKeyedArray(content)) {
            return parseKeyedStructure(parser, content, depth);
        }
        
        Integer colonIdx = parser.findUnquotedColon(content);
        if (colonIdx > 0) {
            return parseObject(parser, depth);
        }
        
        parser.nextLine();
        return ToonPrimitiveDecoder.parse(content);
    }
    
    /**
     * Parse an object (map) structure.
     */
    private static Map<String, Object> parseObject(ToonParser parser, Integer depth) {
        Map<String, Object> result = new Map<String, Object>();
        
        while (parser.hasMoreLines()) {
            String line = parser.getLine(parser.getCurrentLineNumber());
            
            if (String.isBlank(line)) {
                parser.nextLine();
                continue;
            }
            
            Integer lineDepth = parser.getDepth(line);
            
            if (lineDepth < depth) {
                break;
            }
            
            if (lineDepth > depth) {
                parser.nextLine();
                continue;
            }
            
            String content = parser.getCurrentContent(depth);
            
            if (parser.isKeyedArray(content)) {
                parseKeyedArrayIntoMap(parser, content, depth, result);
            } else {
                parseKeyValuePair(parser, content, depth, result);
            }
        }
        
        return result;
    }
    
    /**
     * Parse a single key-value pair into the map.
     */
    private static void parseKeyValuePair(ToonParser parser, String content, Integer depth, Map<String, Object> result) {
        Integer colonIdx = parser.findUnquotedColon(content);
        
        if (colonIdx <= 0) {
            parser.nextLine();
            return;
        }
        
        String key = content.substring(0, colonIdx).trim();
        String value = content.substring(colonIdx + 1).trim();
        
        if (key.startsWith('"')) {
            key = ToonStringValidator.removeQuotes(key);
            key = ToonStringEscaper.unescape(key);
        }
        
        if (String.isBlank(value)) {
            parser.nextLine();
            if (parser.hasMoreLines()) {
                String nextLine = parser.getLine(parser.getCurrentLineNumber());
                if (!String.isBlank(nextLine) && parser.getDepth(nextLine) > depth) {
                    Object nestedValue = parseNestedValue(parser, depth);
                    result.put(key, nestedValue);
                    return;
                }
            }
            result.put(key, '');
        } else {
            parser.nextLine();
            result.put(key, ToonPrimitiveDecoder.parse(value));
        }
    }
    
    /**
     * Parse a nested value (object or array).
     */
    private static Object parseNestedValue(ToonParser parser, Integer parentDepth) {
        if (!parser.hasMoreLines()) {
            return new Map<String, Object>();
        }
        
        String nextLine = parser.getLine(parser.getCurrentLineNumber());
        Integer nextDepth = parser.getDepth(nextLine);
        
        if (nextDepth <= parentDepth) {
            return new Map<String, Object>();
        }
        
        String content = parser.getCurrentContent(nextDepth);
        
        // Check for list format
        if (content.startsWith('- ')) {
            return parseListArray(parser, parentDepth);
        }
        
        if (parser.isArrayHeader(content)) {
            return parseArray(parser, content, nextDepth);
        }
        
        if (parser.isKeyedArray(content)) {
            Map<String, Object> result = new Map<String, Object>();
            parseKeyedArrayIntoMap(parser, content, nextDepth, result);
            return result;
        }
        
        // Default to parsing as object
        return parseObject(parser, nextDepth);
    }
    
    /**
     * Parse an array structure.
     */
    private static List<Object> parseArray(ToonParser parser, String header, Integer depth) {
        String arrayDelimiter = parser.extractDelimiterFromHeader(header);
        
        if (parser.isTabularHeader(header)) {
            return parseTabularArray(parser, header, depth, arrayDelimiter);
        }
        
        Integer colonIdx = header.indexOf(':');
        if (colonIdx < 0) {
            parser.nextLine();
            return new List<Object>();
        }
        
        String afterColon = header.substring(colonIdx + 1).trim();
        
        if (!String.isBlank(afterColon)) {
            parser.nextLine();
            return ToonPrimitiveDecoder.parseDelimitedValues(afterColon, arrayDelimiter);
        }
        
        parser.nextLine();
        
        if (!parser.hasMoreLines()) {
            return new List<Object>();
        }
        
        String nextLine = parser.getLine(parser.getCurrentLineNumber());
        Integer nextDepth = parser.getDepth(nextLine);
        
        if (nextDepth <= depth) {
            return new List<Object>();
        }
        
        String nextContent = parser.getCurrentContent(nextDepth);
        
        if (nextContent.startsWith('- ')) {
            return parseListArray(parser, depth);
        }
        
        List<Object> values = ToonPrimitiveDecoder.parseDelimitedValues(nextContent, arrayDelimiter);
        parser.nextLine();
        return values;
    }
    
    /**
     * Parse tabular array format.
     */
    private static List<Object> parseTabularArray(ToonParser parser, String header, Integer depth, String arrayDelimiter) {
        List<String> fields = parser.extractTabularFields(header, arrayDelimiter);
        List<Object> result = new List<Object>();
        
        parser.nextLine();
        
        while (parser.hasMoreLines()) {
            String line = parser.getLine(parser.getCurrentLineNumber());
            
            if (String.isBlank(line)) {
                parser.nextLine();
                continue;
            }
            
            Integer lineDepth = parser.getDepth(line);
            
            if (lineDepth < depth + 1) {
                break;
            }
            
            if (lineDepth == depth + 1) {
                String rowContent = parser.getCurrentContent(lineDepth);
                Map<String, Object> row = parseTabularRow(rowContent, fields, arrayDelimiter);
                result.add(row);
                parser.nextLine();
            } else {
                parser.nextLine();
            }
        }
        
        return result;
    }
    
    /**
     * Parse a single tabular row.
     */
    private static Map<String, Object> parseTabularRow(String rowContent, List<String> fields, String delimiter) {
        Map<String, Object> row = new Map<String, Object>();
        List<Object> values = ToonPrimitiveDecoder.parseDelimitedValues(rowContent, delimiter);
        
        for (Integer i = 0; i < fields.size() && i < values.size(); i++) {
            row.put(fields[i], values[i]);
        }
        
        return row;
    }
    
    /**
     * Parse list item array format.
     */
    private static List<Object> parseListArray(ToonParser parser, Integer depth) {
        List<Object> result = new List<Object>();
        
        while (parser.hasMoreLines()) {
            String line = parser.getLine(parser.getCurrentLineNumber());
            
            if (String.isBlank(line)) {
                parser.nextLine();
                continue;
            }
            
            Integer lineDepth = parser.getDepth(line);
            
            if (lineDepth < depth + 1) {
                break;
            }
            
            if (lineDepth == depth + 1) {
                String content = parser.getCurrentContent(lineDepth);
                
                if (content.startsWith('- ')) {
                    Object item = parseListItem(parser, content, depth);
                    result.add(item);
                } else {
                    break;
                }
            } else {
                parser.nextLine();
            }
        }
        
        return result;
    }
    
    /**
     * Parse a single list item.
     */
    private static Object parseListItem(ToonParser parser, String content, Integer depth) {
        String itemContent = content.length() > 2 ? content.substring(2).trim() : '';
        
        parser.nextLine();
        
        if (String.isBlank(itemContent)) {
            return new Map<String, Object>();
        }
        
        if (parser.isArrayHeader(itemContent)) {
            return parseArray(parser, itemContent, depth + 1);
        }
        
        Integer colonIdx = parser.findUnquotedColon(itemContent);
        
        if (colonIdx <= 0) {
            return ToonPrimitiveDecoder.parse(itemContent);
        }
        
        Map<String, Object> itemObj = new Map<String, Object>();
        String key = itemContent.substring(0, colonIdx).trim();
        String value = itemContent.substring(colonIdx + 1).trim();
        
        if (key.startsWith('"')) {
            key = ToonStringValidator.removeQuotes(key);
            key = ToonStringEscaper.unescape(key);
        }
        
        if (String.isBlank(value)) {
            Object nestedValue = parseNestedValue(parser, depth + 1);
            itemObj.put(key, nestedValue);
        } else {
            itemObj.put(key, ToonPrimitiveDecoder.parse(value));
        }
        
        parseListItemFields(parser, itemObj, depth);
        
        return itemObj;
    }
    
    /**
     * Parse additional fields in a list item object.
     */
    private static void parseListItemFields(ToonParser parser, Map<String, Object> itemObj, Integer depth) {
        while (parser.hasMoreLines()) {
            String line = parser.getLine(parser.getCurrentLineNumber());
            
            if (String.isBlank(line)) {
                parser.nextLine();
                continue;
            }
            
            Integer lineDepth = parser.getDepth(line);
            
            if (lineDepth < depth + 2) {
                break;
            }
            
            if (lineDepth == depth + 2) {
                String content = parser.getCurrentContent(lineDepth);
                
                if (parser.isKeyedArray(content)) {
                    parseKeyedArrayIntoMap(parser, content, lineDepth, itemObj);
                } else {
                    parseKeyValuePair(parser, content, lineDepth, itemObj);
                }
            } else {
                parser.nextLine();
            }
        }
    }
    
    /**
     * Parse a keyed array structure.
     */
    private static Object parseKeyedStructure(ToonParser parser, String content, Integer depth) {
        Map<String, Object> result = new Map<String, Object>();
        parseKeyedArrayIntoMap(parser, content, depth, result);
        return result;
    }
    
    /**
     * Parse keyed array into existing map.
     */
    private static void parseKeyedArrayIntoMap(ToonParser parser, String content, Integer depth, Map<String, Object> result) {
        Integer bracketIdx = content.indexOf('[');
        String key = content.substring(0, bracketIdx).trim();
        
        if (key.startsWith('"')) {
            key = ToonStringValidator.removeQuotes(key);
            key = ToonStringEscaper.unescape(key);
        }
        
        String arrayHeader = content.substring(bracketIdx);
        List<Object> arrayValue = parseArray(parser, arrayHeader, depth);
        result.put(key, arrayValue);
    }
}
