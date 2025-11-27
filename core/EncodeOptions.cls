/**
 * Configuration options for encoding objects to TOON format.
 */
public class EncodeOptions {
    public Integer indent { get; set; }
    public ToonDelimiter delimiter { get; set; }

    public EncodeOptions() {
        this.indent = 2;
        this.delimiter = ToonDelimiter.COMMA;
    }

    public EncodeOptions(Integer indent, ToonDelimiter delimiter) {
        this.indent = indent;
        this.delimiter = delimiter;
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
