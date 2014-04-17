package filter;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Set the cache headers.
 */
@WebFilter(urlPatterns = "/static/*")
public class CacheControl implements Filter {
    private static final long ONE_DAY_MS = 86400000L;
    private static final long ONE_YEAR_MS = ONE_DAY_MS * 365;
    
    public void destroy() {

    }

    public void init(final FilterConfig config) throws ServletException {

    }
    
    public void doFilter(final ServletRequest request, final ServletResponse response,
                         final FilterChain filterChain) throws IOException, ServletException {
        final HttpServletRequest httpRequest = (HttpServletRequest) request;
        final HttpServletResponse httpResponse = (HttpServletResponse) response;
        final String requestURI = httpRequest.getRequestURI();


        final long now = System.currentTimeMillis();
        httpResponse.setDateHeader("Date", now);
        httpResponse.setDateHeader("Expires", now + ONE_YEAR_MS);

        filterChain.doFilter(request, response);
    }
}
