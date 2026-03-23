"""Test file with refactored Python code.

This file demonstrates the expected output after applying the python-refactor pattern.
"""

from __future__ import annotations

import json
import os
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass
from typing import Any, TypeVar

import requests

# Constants for validation
MIN_PASSWORD_LENGTH = 8
MAX_PASSWORD_LENGTH = 128


# Type variable for generic functions
T = TypeVar("T")


def get_user(user_id: int | None) -> User | None:
    """Retrieve a user by ID.

    Args:
        user_id: The unique identifier for the user.

    Returns:
        The User object if found and active, None otherwise.
    """
    if user_id is None or user_id <= 0:
        return None

    user = fetch_user(user_id)
    if user is None:
        return None

    if not user.is_active:
        return None

    return user


def append_to_list(item: T, target: list[T] | None = None) -> list[T]:
    """Append an item to a target list.

    Args:
        item: The item to append.
        target: The list to append to. Creates a new list if None.

    Returns:
        The list with the item appended.
    """
    if target is None:
        target = []
    target.append(item)
    return target


def read_config(path: str) -> str:
    """Read configuration from a file.

    Args:
        path: The path to the configuration file.

    Returns:
        The file contents as a string.
    """
    with open(path) as file:
        return file.read()


def fetch_data(url: str) -> None:
    """Fetch and process data from a URL.

    Args:
        url: The URL to fetch data from.

    Raises:
        requests.RequestException: If the HTTP request fails.
        ValueError: If the response is not valid JSON.
    """
    try:
        response = requests.get(url)
        response.raise_for_status()
    except requests.RequestException:
        raise

    try:
        data = response.json()
    except ValueError as e:
        raise ValueError("Invalid JSON response") from e

    process(data)


def validate_password(password: str) -> bool:
    """Validate password meets length requirements.

    Args:
        password: The password to validate.

    Returns:
        True if the password is valid, False otherwise.
    """
    if len(password) < MIN_PASSWORD_LENGTH:
        return False
    if len(password) > MAX_PASSWORD_LENGTH:
        return False
    return True


def build_message(parts: list[str]) -> str:
    """Build a message from parts separated by spaces.

    Args:
        parts: The message parts to join.

    Returns:
        The joined message string.
    """
    return " ".join(parts)


def process_items(items: list[str]) -> list[tuple[int, str]]:
    """Process items and return indexed results.

    Args:
        items: The items to process.

    Returns:
        A list of tuples containing index and uppercase item.
    """
    return [(i, item.upper()) for i, item in enumerate(items)]


def get_squares(numbers: list[int]) -> list[int]:
    """Calculate squares of numbers.

    Args:
        numbers: The numbers to square.

    Returns:
        A list of squared numbers.
    """
    return [n**2 for n in numbers]


def process_data() -> Any | None:
    """Load and transform data.

    Returns:
        The transformed data, or None if processing fails.
    """
    data = load_data()
    if data is None:
        return None

    result = transform(data)
    if result is None:
        return None

    return result


def validate_items(items: list[Any]) -> bool:
    """Validate that items list is not empty.

    Args:
        items: The items to validate.

    Returns:
        True if items is non-empty, False otherwise.
    """
    return bool(items)


def check_active(user: User) -> bool | None:
    """Check if a user is active.

    Args:
        user: The user to check.

    Returns:
        True if active, False if inactive, None if status is unclear.
    """
    if user.is_active:
        return True
    if not user.is_active:
        return False
    return None


def has_valid_item(items: list[Any]) -> bool:
    """Check if any item is valid.

    Args:
        items: The items to check.

    Returns:
        True if at least one item is valid.
    """
    return any(item.is_valid for item in items)


def all_items_valid(items: list[Any]) -> bool:
    """Check if all items are valid.

    Args:
        items: The items to check.

    Returns:
        True if all items are valid.
    """
    return all(item.is_valid for item in items)


def get_or_default(d: dict[str, T], key: str, default: T) -> T:
    """Get a value from a dictionary with a default.

    Args:
        d: The dictionary to search.
        key: The key to look up.
        default: The default value if key is not found.

    Returns:
        The value for key, or default if not found.
    """
    return d.get(key, default)


def add_to_group(groups: dict[str, list[T]], key: str, item: T) -> None:
    """Add an item to a group in a dictionary.

    Args:
        groups: The dictionary of groups.
        key: The group key.
        item: The item to add.
    """
    groups.setdefault(key, []).append(item)


def calculate_total(items: list[Any], discount: float) -> float:
    """Calculate the total price after discount.

    Args:
        items: The items with prices.
        discount: The discount rate (0.0 to 1.0).

    Returns:
        The total price after applying the discount.
    """
    total = sum(item.price for item in items)
    return total * (1 - discount)


def process_value(value: str | int | Any) -> str | int | Any:
    """Process a value based on its type.

    Args:
        value: The value to process.

    Returns:
        Uppercase string, doubled int, or unchanged value.
    """
    if isinstance(value, str):
        return value.upper()
    if isinstance(value, int):
        return value * 2
    return value


def count_items(items: list[Any]) -> Counter:
    """Count occurrences of items.

    Args:
        items: The items to count.

    Returns:
        A Counter with item counts.
    """
    return Counter(items)


def load_config(path: str) -> dict[str, Any]:
    """Load configuration from a JSON file.

    Args:
        path: The path to the configuration file.

    Returns:
        The parsed configuration dictionary.

    Raises:
        ConfigError: If the configuration file is not found.
    """
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError as e:
        raise ConfigError(f"Config not found: {path}") from e


@dataclass
class User:
    """Represents a user in the system.

    Attributes:
        id: The unique identifier for the user.
        name: The user's display name.
        email: The user's email address.
        is_active: Whether the user account is active.
    """

    id: int
    name: str
    email: str
    is_active: bool = True


# Placeholder functions for compilation
def fetch_user(user_id: int) -> User | None:
    """Fetch a user from the database."""
    return None


def process(data: Any) -> None:
    """Process data."""
    pass


def load_data() -> Any | None:
    """Load data from source."""
    return None


def transform(data: Any) -> Any | None:
    """Transform data."""
    return None


class ConfigError(Exception):
    """Raised when configuration loading fails."""

    pass
