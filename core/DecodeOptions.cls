/**
 * Configuration options for decoding TOON format to objects.
 */
public class DecodeOptions {
    private static final PathExpansion DEFAULT_PATH_EXPANSION = PathExpansion.NONE;
    private static final Boolean DEFAULT_STRICT_MODE = false;
    
    public PathExpansion pathExpansion { get; set; }
    public Boolean strictMode { get; set; }

    public DecodeOptions() {
        this.pathExpansion = DEFAULT_PATH_EXPANSION;
        this.strictMode = DEFAULT_STRICT_MODE;
    }

    public DecodeOptions(PathExpansion pathExpansion, Boolean strictMode) {
        this.pathExpansion = pathExpansion;
        this.strictMode = strictMode;
    }
}
