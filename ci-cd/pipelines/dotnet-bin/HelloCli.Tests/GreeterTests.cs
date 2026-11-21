using HelloCli;
using Xunit;

namespace HelloCli.Tests;

public class GreeterTests
{
    [Fact]
    public void GreetReturnsGreeting()
    {
        Assert.Equal("Hello, xUnit!", Greeter.Greet("xUnit"));
    }
}
