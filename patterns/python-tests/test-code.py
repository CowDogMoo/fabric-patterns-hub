"""Calculator module providing mathematical operations.

This module contains a Calculator class and utility functions for
performing various mathematical calculations.
"""

import math
from typing import List, Optional


class Calculator:
    """A calculator with configurable precision for floating-point operations."""

    def __init__(self, precision: int = 2):
        """Initialize calculator with specified decimal precision.

        Args:
            precision: Number of decimal places for rounding results.
        """
        self.precision = precision

    def add(self, a: float, b: float) -> float:
        """Add two numbers.

        Args:
            a: First number.
            b: Second number.

        Returns:
            Sum of a and b, rounded to calculator's precision.
        """
        return round(a + b, self.precision)

    def subtract(self, a: float, b: float) -> float:
        """Subtract b from a.

        Args:
            a: Number to subtract from.
            b: Number to subtract.

        Returns:
            Difference of a and b, rounded to calculator's precision.
        """
        return round(a - b, self.precision)

    def multiply(self, a: float, b: float) -> float:
        """Multiply two numbers.

        Args:
            a: First number.
            b: Second number.

        Returns:
            Product of a and b, rounded to calculator's precision.
        """
        return round(a * b, self.precision)

    def divide(self, a: float, b: float) -> float:
        """Divide a by b.

        Args:
            a: Dividend.
            b: Divisor.

        Returns:
            Quotient of a and b, rounded to calculator's precision.

        Raises:
            ValueError: If b is zero.
        """
        if b == 0:
            raise ValueError("cannot divide by zero")
        return round(a / b, self.precision)

    def power(self, base: float, exponent: float) -> float:
        """Raise base to the power of exponent.

        Args:
            base: The base number.
            exponent: The exponent.

        Returns:
            base raised to exponent, rounded to calculator's precision.
        """
        return round(math.pow(base, exponent), self.precision)

    def square_root(self, n: float) -> float:
        """Calculate the square root of a number.

        Args:
            n: Number to find square root of.

        Returns:
            Square root of n, rounded to calculator's precision.

        Raises:
            ValueError: If n is negative.
        """
        if n < 0:
            raise ValueError("cannot calculate square root of negative number")
        return round(math.sqrt(n), self.precision)


def average(numbers: List[float]) -> float:
    """Calculate the average of a list of numbers.

    Args:
        numbers: List of numbers to average.

    Returns:
        Arithmetic mean of the numbers.

    Raises:
        ValueError: If the list is empty.
    """
    if not numbers:
        raise ValueError("cannot calculate average of empty list")
    return sum(numbers) / len(numbers)


def maximum(numbers: List[float]) -> float:
    """Find the maximum value in a list of numbers.

    Args:
        numbers: List of numbers to search.

    Returns:
        The largest number in the list.

    Raises:
        ValueError: If the list is empty.
    """
    if not numbers:
        raise ValueError("cannot find maximum of empty list")
    return max(numbers)


def minimum(numbers: List[float]) -> float:
    """Find the minimum value in a list of numbers.

    Args:
        numbers: List of numbers to search.

    Returns:
        The smallest number in the list.

    Raises:
        ValueError: If the list is empty.
    """
    if not numbers:
        raise ValueError("cannot find minimum of empty list")
    return min(numbers)


def is_even(n: int) -> bool:
    """Check if a number is even.

    Args:
        n: Integer to check.

    Returns:
        True if n is even, False otherwise.
    """
    return n % 2 == 0


def is_prime(n: int) -> bool:
    """Check if a number is prime.

    Args:
        n: Integer to check.

    Returns:
        True if n is prime, False otherwise.
    """
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    for i in range(3, int(math.sqrt(n)) + 1, 2):
        if n % i == 0:
            return False
    return True


def factorial(n: int) -> int:
    """Calculate the factorial of a non-negative integer.

    Args:
        n: Non-negative integer.

    Returns:
        n! (n factorial).

    Raises:
        ValueError: If n is negative.
    """
    if n < 0:
        raise ValueError("cannot calculate factorial of negative number")
    if n <= 1:
        return 1
    return n * factorial(n - 1)


def fibonacci(n: int) -> int:
    """Calculate the nth Fibonacci number.

    Args:
        n: Position in Fibonacci sequence (0-indexed).

    Returns:
        The nth Fibonacci number.

    Raises:
        ValueError: If n is negative.
    """
    if n < 0:
        raise ValueError("cannot calculate fibonacci of negative index")
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b
