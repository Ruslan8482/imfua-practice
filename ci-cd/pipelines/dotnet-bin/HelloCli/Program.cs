using System;

namespace HelloCli;

public static class Greeter
{
    public static string Greet(string name) => $"Hello, {name}!";
}

public static class Program
{
    public static void Main(string[] args)
    {
        var name = args.Length > 0 ? args[0] : "dotnet";
        Console.WriteLine(Greeter.Greet(name));
    }
}
