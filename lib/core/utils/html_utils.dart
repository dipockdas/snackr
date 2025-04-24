/// Utility functions for handling HTML content
class HtmlUtils {
  /// Decode HTML entities and strip HTML tags from a string
  static String decodeHtml(String html) {
    if (html.isEmpty) return '';
    
    // Handle CDATA sections first
    if (html.contains('<![CDATA[') && html.contains(']]>')) {
      html = html.replaceAll('<![CDATA[', '').replaceAll(']]>', '');
    }
    
    // Simple approach - directly replace entities, no HTML parsing
    String result = html;
    
    // Strip HTML tags first
    result = result.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Replace common entities
    result = result
        .replaceAll('&apos;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#39;', "'")
        .replaceAll('&#34;', '"')
        .replaceAll('&#38;', '&')
        .replaceAll('&#60;', '<')
        .replaceAll('&#62;', '>')
        .replaceAll('&#160;', ' ');
    
    return result;
  }
}