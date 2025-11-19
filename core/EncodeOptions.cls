/**
 * Configuration options for encoding objects to TOON format.
 */
public class EncodeOptions {
    public Integer indent { get; set; }
    public ToonDelimiter delimiter { get; set; }
    public Boolean lengthMarker { get; set; }

    public EncodeOptions() {
        this.indent = 2;
        this.delimiter = ToonDelimiter.COMMA;
        this.lengthMarker = false;
    }

    public EncodeOptions(Integer indent, ToonDelimiter delimiter, Boolean lengthMarker) {
        this.indent = indent;
        this.delimiter = delimiter;
        this.lengthMarker = lengthMarker;
    }

    public String getDelimiterString() {
        switch on this.delimiter {
            when COMMA {
                return ',';
            }
            when TAB {
                return '\t';
            }
            when PIPE {
                return '|';
            }
            when else {
                return ',';
            }
        }
    }
}
