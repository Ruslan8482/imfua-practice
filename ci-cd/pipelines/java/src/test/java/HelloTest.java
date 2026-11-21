import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

public class HelloTest {
    @Test
    void greetReturnsGreeting() {
        assertEquals("Hello, Java!", new Hello().greet("Java"));
    }
}
