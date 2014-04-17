import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;
import java.util.HashSet;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * A class extending {@link javax.ws.rs.core.Application} and annotated with @ApplicationPath is the Java EE 6
 * "no XML" approach to activating JAX-RS.
 * <p/>
 * <p>
 * Resources are served relative to the servlet path specified in the {@link javax.ws.rs.ApplicationPath}
 * annotation.
 * </p>
 */
@ApplicationPath("/tests/")
public class JaxRsActivator extends Application {
    private static final Logger LOGGER = LoggerFactory.getLogger(JaxRsActivator.class);
    private final HashSet<Class<?>> classes = new HashSet<Class<?>>();

    public JaxRsActivator() {
        LOGGER.debug("ENTER JaxRsActivator()");

        // Endpoints
        classes.add(PerformanceTests.class);
    }

    @Override
    public Set<Class<?>> getClasses() {
        return classes;
    }
}
