<?php

declare(strict_types=1);

use App\Greeter;
use PHPUnit\Framework\TestCase;

final class GreeterTest extends TestCase
{
    public function testGreet(): void
    {
        $greeter = new Greeter();
        self::assertSame('Hello, World!', $greeter->greet('World'));
    }
}
