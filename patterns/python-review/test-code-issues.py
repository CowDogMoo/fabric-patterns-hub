"""Test file with various Python issues for code review.

This file demonstrates common problems that the python-review pattern should identify.
"""

import os, sys, json  # Multiple imports on one line - PEP 8 violation
from typing import *  # Wildcard import - PEP 8 violation
import requests
from myapp.models import User
from myapp.utils import helper

# Global mutable state - should be avoided
db_connection = None
cache = {}  # Mutable global


# Missing type hints on public function
def get_user(user_id):
    """Get user from database."""
    # SQL injection vulnerability!
    query = f"SELECT * FROM users WHERE id = {user_id}"
    cursor = db_connection.cursor()
    cursor.execute(query)
    return cursor.fetchone()


# Mutable default argument - critical bug
def append_to_list(item, target=[]):
    """Append item to target list."""
    target.append(item)
    return target


# Deep nesting - should use early returns
def ProcessUser(userData):  # Wrong naming convention - should be snake_case
    if userData is not None:
        if userData.get("active"):
            if userData.get("verified"):
                if userData.get("email"):
                    # Deeply nested logic
                    return send_notification(userData["email"])
                else:
                    return None
            else:
                return None
        else:
            return None
    else:
        return None


# Bare except clause - catches everything
def fetch_data(url):
    try:
        response = requests.get(url)
        data = response.json()
        process_data(data)
        save_data(data)
        notify_users(data)  # Too much in try block
    except:  # Bare except - bad practice
        pass  # Silently ignoring errors


# Missing docstring for public class
class userService:  # Wrong naming - should be CapWords
    MAX_RETRIES = 3

    def __init__(self, db):
        self.db = db
        self._cache = {}

    # Missing type hints
    def GetUser(self, user_id):  # Wrong naming - should be get_user
        if user_id in self._cache:
            return self._cache[user_id]
        user = self.db.find_user(user_id)
        self._cache[user_id] = user
        return user

    # Command injection vulnerability
    def run_backup(self, filename):
        import subprocess

        # Shell=True with user input - command injection!
        subprocess.run(f"tar -czf {filename} /data", shell=True)


# Comparing to True/False - PEP 8 violation
def check_active(user):
    if user.is_active == True:  # Should be: if user.is_active
        return True
    elif user.is_active == False:  # Should be: if not user.is_active
        return False
    return None


# Using type() instead of isinstance
def process_value(value):
    if type(value) == str:  # Should use isinstance()
        return value.upper()
    elif type(value) == int:
        return value * 2
    return value


# Inefficient string concatenation in loop
def build_report(items):
    report = ""
    for item in items:
        report += f"- {item}\n"  # Inefficient - use join()
    return report


# Magic numbers
def validate_password(password):
    if len(password) < 8:  # Magic number
        return False
    if len(password) > 128:  # Magic number
        return False
    return True


# Complex comprehension - hard to read
def transform_data(data):
    return [
        process(x, y)
        for outer in data
        for x in outer.items
        for y in outer.values
        if x.valid
        if y.active
        if not x.deleted
    ]


# Not using context manager for file
def read_file(path):
    f = open(path)  # Should use: with open(path) as f
    content = f.read()
    f.close()  # Can fail if read() raises
    return content


# Hardcoded credentials - security issue
API_KEY = "sk-1234567890abcdef"
DATABASE_URL = "postgresql://admin:password123@localhost/db"


# Using is for string comparison
def check_status(status):
    if status is "active":  # Should use ==
        return True
    return False


# Unused import and variable
unused_var = 42


# Missing return type hint, inconsistent returns
def find_user(user_id: int):
    user = db_connection.find(user_id)
    if user:
        return user  # Returns User
    # Implicit None return - inconsistent


# Type checking with string
def validate_input(value):
    if type(value).__name__ == "str":  # Use isinstance
        return True
    return False


class DataProcessor:
    """Process data from various sources.

    Attributes:
        source: The data source.
    """

    def __init__(self, source):
        self.source = source
        self.results = []

    def process(self, data):
        # Using len() for empty check
        if len(data) == 0:  # Should be: if not data
            return

        # Not using enumerate
        for i in range(len(data)):  # Should use: for i, item in enumerate(data)
            item = data[i]
            self.results.append(item)

    # Property with side effects - bad practice
    @property
    def count(self):
        self._update_stats()  # Side effect in property
        return len(self.results)

    def _update_stats(self):
        pass


# Main without if __name__ guard
def main():
    print("Starting application")


main()  # Runs on import - should be guarded
