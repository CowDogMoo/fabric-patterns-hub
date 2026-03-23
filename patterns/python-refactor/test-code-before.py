"""Test file with various Python anti-patterns for refactoring.

This file demonstrates common issues that the python-refactor pattern should fix.
"""

import os
import sys

# Global mutable state - should be avoided
db_connection = None
cache = {}


# Deep nesting anti-pattern
def get_user(user_id):
    if user_id is not None:
        if user_id > 0:
            user = fetch_user(user_id)
            if user is not None:
                if user.is_active:
                    return user
                else:
                    return None
            else:
                return None
        else:
            return None
    else:
        return None


# Mutable default argument - critical bug
def append_to_list(item, target=[]):
    target.append(item)
    return target


# Resource leak - no context manager
def read_config(path):
    file = open(path)
    data = file.read()
    file.close()
    return data


# Poor error handling - bare except
def fetch_data(url):
    try:
        response = requests.get(url)
        data = response.json()
        process(data)
    except:
        pass


# Magic numbers
def validate_password(password):
    if len(password) < 8:
        return False
    if len(password) > 128:
        return False
    return True


# Inefficient string concatenation
def build_message(parts):
    msg = ""
    for part in parts:
        msg += part + " "
    return msg


# Manual index tracking instead of enumerate
def process_items(items):
    results = []
    for i in range(len(items)):
        item = items[i]
        results.append((i, item.upper()))
    return results


# Not using list comprehension
def get_squares(numbers):
    squares = []
    for n in numbers:
        squares.append(n**2)
    return squares


# Variables declared too early
def process_data():
    data = None
    error = None
    result = None

    data = load_data()
    if data is None:
        return None

    result = transform(data)
    if result is None:
        return None

    return result


# Using len() for empty check
def validate_items(items):
    if len(items) == 0:
        return False
    return True


# Comparing to True/False
def check_active(user):
    if user.is_active == True:
        return True
    elif user.is_active == False:
        return False
    return None


# Not using any()/all()
def has_valid_item(items):
    for item in items:
        if item.is_valid:
            return True
    return False


def all_items_valid(items):
    for item in items:
        if not item.is_valid:
            return False
    return True


# Not using dict methods
def get_or_default(d, key, default):
    if key in d:
        return d[key]
    else:
        return default


def add_to_group(groups, key, item):
    if key not in groups:
        groups[key] = []
    groups[key].append(item)


# Missing type hints and docstring
def calculate_total(items, discount):
    total = 0.0
    for item in items:
        total += item.price
    return total * (1 - discount)


# Using type() instead of isinstance
def process_value(value):
    if type(value) == str:
        return value.upper()
    elif type(value) == int:
        return value * 2
    return value


# Manual counter
def count_items(items):
    counts = {}
    for item in items:
        if item in counts:
            counts[item] += 1
        else:
            counts[item] = 1
    return counts


# Exception handling that loses context
def load_config(path):
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError:
        raise ConfigError("Config not found")


# Class without dataclass
class User:
    def __init__(self, id, name, email, is_active):
        self.id = id
        self.name = name
        self.email = email
        self.is_active = is_active

    def __repr__(self):
        return f"User(id={self.id}, name={self.name}, email={self.email})"

    def __eq__(self, other):
        if not isinstance(other, User):
            return False
        return self.id == other.id and self.name == other.name


# Placeholder functions for compilation
def fetch_user(user_id):
    return None


def process(data):
    pass


def load_data():
    return None


def transform(data):
    return None


class ConfigError(Exception):
    pass
